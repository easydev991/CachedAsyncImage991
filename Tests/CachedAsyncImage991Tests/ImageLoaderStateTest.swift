@testable import CachedAsyncImage991
import XCTest

final class ImageLoaderStateTest: XCTestCase {
    private typealias State = ImageLoader.State
    
    func testLoading() {
        let sut = State.loading
        XCTAssertTrue(sut.isLoading)
        XCTAssertNil(sut.uiImage)
    }
    
    func testError() {
        let sut = State.error
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.uiImage)
    }
    
    func testReady() {
        let systemPersonImage = UIImage(systemName: "person")!
        let sut = State.ready(systemPersonImage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.uiImage)
        XCTAssertEqual(sut.uiImage, systemPersonImage)
    }
}
