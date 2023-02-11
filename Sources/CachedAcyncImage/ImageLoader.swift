import Combine
import UIKit.UIImage

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published private(set) var isLoading = false
    private var url: URL?
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    private let imageProcessingQueue = DispatchQueue(label: "image-processing")

    init(url: URL?, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }

    deinit { cancellable?.cancel() }

    func load() {
        guard let url = url, !isLoading else { return }
        if let image = cache?[url] {
            self.image = image
            return
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .map(UIImage.init)
            .replaceError(with: nil)
            .subscribe(on: imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.isLoading = true },
                receiveOutput: { [weak self] loadedImage in
                    guard let self else { return }
                    loadedImage.map { self.cache?[url] = $0 }
                },
                receiveCompletion: { [weak self] _ in self?.onFinish() },
                receiveCancel: { [weak self] in self?.onFinish() }
            )
            .sink { [weak self] in self?.image = $0 }
    }
}

private extension ImageLoader {
    func onFinish() { isLoading = false }
}
