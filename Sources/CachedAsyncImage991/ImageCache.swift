import Foundation
import UIKit.UIImage

protocol ImageCacheServiceProtocol: AnyObject {
    subscript(key: URL) -> UIImage? { get set }
}

final class ImageCacheService: ImageCacheServiceProtocol {
    private init() {}
    
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()

    static let shared = ImageCacheService()

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set {
            if let newValue {
                cache.setObject(newValue, forKey: key as NSURL)
            } else {
                cache.removeObject(forKey: key as NSURL)
            }
        }
    }
}
