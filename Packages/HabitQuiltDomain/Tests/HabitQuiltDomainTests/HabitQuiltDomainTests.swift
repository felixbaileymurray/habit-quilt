import XCTest
@testable import HabitQuiltDomain

final class HabitQuiltDomainTests: XCTestCase {
    func testStubPackageLoads() {
        XCTAssertEqual(QuiltLayout.columnCounts().first, 1)
    }
}
