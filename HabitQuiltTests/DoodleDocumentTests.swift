import XCTest
@testable import HabitQuilt
import HabitQuiltDomain

final class DoodleDocumentTests: XCTestCase {
    func testDoodleJSONDoesNotIncludeDotGrid() throws {
        let doc = DoodleDocument(
            v: 1,
            paletteId: "riso-2026a",
            paper: .light,
            ops: [
                .stroke(
                    tool: .pen,
                    ink: .blue,
                    points: [StrokePoint(x: 0, y: 0, pressure: 0.5, ms: 0)]
                ),
            ]
        )
        let data = try doc.encodeJSON()
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertFalse(json.lowercased().contains("dot"))
        XCTAssertFalse(json.lowercased().contains("grid"))

        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(object?["v"])
        XCTAssertNotNil(object?["paletteId"])
        XCTAssertNotNil(object?["paper"])
        XCTAssertNotNil(object?["ops"])
        XCTAssertNil(object?["dotGrid"])
        XCTAssertNil(object?["dot_grid"])
        XCTAssertFalse(DoodleDocument.containsForbiddenKeys(object as Any))
    }
}
