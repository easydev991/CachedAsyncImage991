import UIKit.UIImage

enum ImageLoadingError: Error, LocalizedError {
    case invalidURL
    case invalidImageData(String)
    case cancelled(String)
    case networkError(_ stringURL: String, _ description: String, _ code: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Попытка загрузки без URL"
        case let .invalidImageData(stringURL):
            "Не смогли создать картинку из данных для URL: \(stringURL)"
        case let .cancelled(stringURL):
            "Отменили загрузку для URL: \(stringURL)"
        case let .networkError(stringURL, description, code):
            """
            Ошибка загрузки для \(stringURL)
            Описание: \(description)
            Код ошибки: \(code)
            """
        }
    }
}

protocol ImageLoaderProtocol: Sendable {
    func loadImage(for url: URL?) async throws -> UIImage
    func getCachedImage(for url: URL?) -> UIImage?
}

struct ImageLoader: ImageLoaderProtocol {
    private let cache: ImageCacheServiceProtocol
    private let urlSession: URLSession
    
    init(
        cache: ImageCacheServiceProtocol = ImageCacheService.shared,
        urlSession: URLSession = .shared
    ) {
        self.cache = cache
        self.urlSession = urlSession
    }
    
    func getCachedImage(for url: URL?) -> UIImage? {
        guard let url else { return nil }
        return cache[url]
    }
    
    func loadImage(for url: URL?) async throws -> UIImage {
        guard let url else {
            throw ImageLoadingError.invalidURL
        }
        if let cached = cache[url] {
            return cached
        }
        do {
            let (data, _) = try await urlSession.data(from: url)
            guard let image = UIImage(data: data) else {
                throw ImageLoadingError.invalidImageData(url.absoluteString)
            }
            cache[url] = image
            return image
        } catch {
            let stringURL = url.absoluteString
            let errorCode = (error as NSError).code
            if errorCode == -999 {
                throw ImageLoadingError.cancelled(stringURL)
            } else {
                let description = error.localizedDescription
                throw ImageLoadingError.networkError(stringURL, description, errorCode)
            }
        }
    }
}
