import Foundation
import UIKit.UIImage
import OSLog

final class ImageLoader: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ImageLoader")
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading = false
    private let url: URL?
    private let cache = ImageCacheService.shared

    init(url: URL?) { self.url = url }

    @MainActor
    func load() async {
        guard let url, !isLoading else {
            logger.debug("Skipping this call to `load()` method")
            return
        }
        if let image = cache[url], self.image != image {
            logger.debug("Using a cached image for url: \(url, privacy: .public)")
            self.image = image
            return
        }
        isLoading = true
        logger.debug("Loading an image from url: \(url, privacy: .public)")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                cache[url] = loadedImage
                self.image = loadedImage
                logger.debug("Successfully got an image from url: \(url, privacy: .public)")
            } else {
                logger.error("Failed to create a UIImage with data")
            }
        } catch {
            logger.error(
                """
                Failed to load image from URL: \(url, privacy: .public)
                Error: \(error.localizedDescription, privacy: .public)
                """
            )
        }
        isLoading = false
    }
}
