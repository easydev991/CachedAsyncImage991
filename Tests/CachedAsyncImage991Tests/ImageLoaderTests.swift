@testable import CachedAsyncImage991
import Testing
import UIKit

struct ImageLoaderTests {
    private let cache = MockCache()
    
    @Test func cachedImageShouldReturnNilForInvalidURL() {
        let loader = ImageLoader(cache: cache)
        #expect(loader.getCachedImage(for: nil) == nil)
    }
    
    @Test func cachedImageShouldReturnCachedValue() throws {
        let url = try #require(URL(string: "https://example.com/image"))
        let image = UIImage()
        cache[url] = image
        let loader = ImageLoader(cache: cache)
        #expect(loader.getCachedImage(for: url) == image)
    }
    
    @Test func shouldNotLoadWhenCached() async throws {
        let url = try #require(URL(string: "https://example.com/image"))
        let image = UIImage()
        cache[url] = image
        let loader = ImageLoader(cache: cache)
        let result = try await loader.loadImage(for: url)
        #expect(result == image)
    }
}

private final class MockCache: ImageCacheServiceProtocol {
    var storage = [URL: UIImage]()
    
    subscript(key: URL) -> UIImage? {
        get { storage[key] }
        set { storage[key] = newValue }
    }
}
