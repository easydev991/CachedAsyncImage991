import Foundation
import UIKit.UIImage

protocol ImageCacheServiceProtocol: AnyObject, Sendable {
    subscript(key: URL) -> UIImage? { get set }
}

final class ImageCacheService: ImageCacheServiceProtocol, @unchecked Sendable {
    private init() {}
    private let queue = DispatchQueue(
        label: "com.cachedAsyncImage991.imageCacheService",
        qos: .userInitiated,
        attributes: .concurrent
    )
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    static let shared = ImageCacheService()

    subscript(_ key: URL) -> UIImage? {
        get {
            var result: UIImage?
            queue.sync {
                result = cache.object(forKey: key as NSURL)
            }
            return result
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                guard let self else { return }
                if let newValue {
                    self.cache.setObject(newValue, forKey: key as NSURL)
                } else {
                    self.cache.removeObject(forKey: key as NSURL)
                }
            }
        }
    }
}
