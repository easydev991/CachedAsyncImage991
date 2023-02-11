import Foundation
import UIKit.UIImage

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published private(set) var isLoading = false
    private var url: URL?
    private var cache: ImageCache?

    init(url: URL?, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }

    @MainActor
    func load() async {
        guard let url = url, !isLoading else { return }
        if let image = cache?[url] {
            self.image = image
            return
        }
        isLoading = true
        if let (data, _) = try? await URLSession.shared.data(from: url),
           let loadedImage = UIImage(data: data) {
            cache?[url] = loadedImage
            self.image = loadedImage
        }
        isLoading = false
    }
}
