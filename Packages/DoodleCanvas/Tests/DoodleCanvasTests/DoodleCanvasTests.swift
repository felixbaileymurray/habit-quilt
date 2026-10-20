import XCTest
@testable import DoodleCanvas

final class DoodleCanvasTests: XCTestCase {
    func testDotGridDefaultsHidden() {
        XCTAssertFalse(DotGridSessionState().isVisible)
    }
}
