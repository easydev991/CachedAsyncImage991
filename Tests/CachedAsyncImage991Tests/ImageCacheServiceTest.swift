@testable import CachedAsyncImage991
import XCTest

final class ImageCacheServiceTest: XCTestCase {
    private let testURL = URL(string: "testURL")!
    
    func testSaveAndRead() {
        let sut = ImageCacheService.shared
        XCTAssertNil(sut[testURL])
        let systemPersonImage = UIImage(systemName: "person")!
        sut[testURL] = systemPersonImage
        XCTAssertNotNil(sut[testURL])
        XCTAssertEqual(sut[testURL], systemPersonImage)
    }
}
