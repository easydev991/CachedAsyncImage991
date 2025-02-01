@testable import CachedAsyncImage991
import Testing
import UIKit

struct ImageCacheServiceTests {
    @Test func sharedInstanceIsSingleton() {
        let instance1 = ImageCacheService.shared
        let instance2 = ImageCacheService.shared
        #expect(instance1 === instance2)
    }
    
    @Test func storeAndRetrieveImage() throws {
        let cache = ImageCacheService.shared
        let url = try #require(URL(string: "https://example.com/image_\(UUID())"))
        #expect(cache[url] == nil)
        let image = UIImage()
        cache[url] = image
        #expect(cache[url] === image)
    }
    
    @Test func removeImageBySettingNil() throws {
        let cache = ImageCacheService.shared
        let url = try #require(URL(string: "https://example.com/image_\(UUID())"))
        let image = UIImage()
        cache[url] = image
        cache[url] = nil
        #expect(cache[url] == nil)
    }
    
    @Test func overwriteExistingImage() throws {
        let cache = ImageCacheService.shared
        let url = try #require(URL(string: "https://example.com/image_\(UUID())"))
        let image1 = UIImage()
        let image2 = UIImage()
        cache[url] = image1
        cache[url] = image2
        #expect(cache[url] === image2)
    }
}
