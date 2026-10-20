import XCTest
@testable import HabitQuilt
import DoodleCanvas

@MainActor
final class DoodleDocumentTests: XCTestCase {
    func testDoodleJSONDoesNotIncludeDotGrid() throws {
        var doc = DoodleDocument(paper: .light)
        doc.ops = [
            .stroke(
                tool: .pen,
                ink: .blue,
                points: [DoodlePoint(x: 0, y: 0, pressure: 0.5, tMs: 0)]
            ),
        ]
        let data = try DoodleCodec.encode(doc)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertFalse(json.lowercased().contains("dot"))
        XCTAssertFalse(json.lowercased().contains("grid"))
        XCTAssertTrue(DoodleCodec.serializedJSONOmitsDotGrid(data))

        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(object?["v"])
        XCTAssertNotNil(object?["paletteId"])
        XCTAssertNotNil(object?["paper"])
        XCTAssertNotNil(object?["ops"])
        XCTAssertNil(object?["dotGrid"])
        XCTAssertNil(object?["dot_grid"])
        XCTAssertNil(object?["showsDotGrid"])
    }

    func testSessionUIDotGridNotEncoded() throws {
        let session = DoodleSession(ui: DoodleSessionUIState(showsDotGrid: true))
        session.beginStroke(at: DoodlePoint(x: 10, y: 10, pressure: 0.5, tMs: 0))
        session.endStroke()
        let data = try DoodleCodec.encode(session.document)
        XCTAssertTrue(DoodleCodec.serializedJSONOmitsDotGrid(data))
        XCTAssertTrue(session.ui.showsDotGrid)
    }
}
