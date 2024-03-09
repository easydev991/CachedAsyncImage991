import Foundation
import UIKit.UIImage
import OSLog

final class ImageLoader: ObservableObject {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "CachedAsyncImage991",
        category: "ImageLoader"
    )
    @Published private(set) var state: State?
    private let url: URL?
    private let cache = ImageCacheService.shared

    init(url: URL?) { self.url = url }

    @MainActor
    func load() async {
        guard let url, state?.uiImage == nil else {
            logger.debug("Пропускаем загрузку картинки")
            return
        }
        if let image = cache[url], state?.uiImage != image {
            logger.debug("Используем картинку из кэша по URL: \(url, privacy: .public)")
            state = .ready(image)
            return
        }
        state = .loading
        logger.debug("Загружаем картинку по URL: \(url, privacy: .public)")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                cache[url] = loadedImage
                state = .ready(loadedImage)
                logger.debug("Успешно загрузили картинку по URL: \(url, privacy: .public)")
            } else {
                logger.error("Не удалось создать картинку из Data")
                state = .error
            }
        } catch {
            logger.error(
                """
                Не удалось загрузить картинку по URL: \(url, privacy: .public)
                Ошибка: \(error.localizedDescription, privacy: .public)
                """
            )
            state = .error
        }
    }
}

extension ImageLoader {
    enum State: Equatable {
        case loading
        case ready(UIImage)
        case error
        var isLoading: Bool { self == .loading }
        var uiImage: UIImage? {
            if case let .ready(uiImage) = self { uiImage } else { nil }
        }
    }
}
