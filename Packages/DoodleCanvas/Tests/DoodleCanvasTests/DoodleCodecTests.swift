import XCTest
@testable import DoodleCanvas

final class DoodleCodecTests: XCTestCase {
    func testRoundTripStrokeDocument() throws {
        let document = DoodleDocument(
            paper: .dark,
            ops: [
                .stroke(
                    tool: .pen,
                    ink: .teal,
                    points: [
                        DoodlePoint(x: 10, y: 20, pressure: 0.4, tMs: 0),
                        DoodlePoint(x: 30, y: 40, pressure: 0.8, tMs: 16),
                    ]
                ),
            ]
        )
        let data = try DoodleCodec.encode(document)
        let decoded = try DoodleCodec.decode(data)
        XCTAssertEqual(decoded, document)
    }

    func testJSONUsesInkIDsNotHex() throws {
        let document = DoodleDocument(
            ops: [.stroke(tool: .pen, ink: .burgundy, points: [DoodlePoint(x: 1, y: 2)])]
        )
        let string = try DoodleCodec.encodeString(document)
        XCTAssertTrue(string.contains("\"burgundy\""))
        XCTAssertFalse(string.contains("#"))
        XCTAssertFalse(string.lowercased().contains("0x"))
    }

    func testSerializedJSONOmitsDotGrid() throws {
        // Dot-grid lives only on session UI — never on the document.
        let document = DoodleDocument(ops: [
            .stroke(tool: .pencil, ink: .yellow, points: [DoodlePoint(x: 5, y: 5)]),
        ])
        let data = try DoodleCodec.encode(document)
        XCTAssertTrue(DoodleCodec.serializedJSONOmitsDotGrid(data))
        let string = String(data: data, encoding: .utf8) ?? ""
        XCTAssertFalse(string.contains("dotGrid"))
        XCTAssertFalse(string.contains("showsDotGrid"))
    }

    func testDecodeFixture() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "sample-stroke", withExtension: "json", subdirectory: "Fixtures")
                ?? Bundle.module.url(forResource: "sample-stroke", withExtension: "json")
        )
        let data = try Data(contentsOf: url)
        let document = try DoodleCodec.decode(data)
        XCTAssertEqual(document.v, 1)
        XCTAssertEqual(document.paletteId, RisoPalette.id)
        XCTAssertEqual(document.paper, .light)
        XCTAssertEqual(document.ops.count, 1)
        if case let .stroke(tool, ink, points) = document.ops[0] {
            XCTAssertEqual(tool, .pen)
            XCTAssertEqual(ink, .blue)
            XCTAssertEqual(points.count, 3)
        } else {
            XCTFail("Expected stroke op")
        }
    }

    func testUnsupportedVersion() {
        let json = #"{"v":99,"paletteId":"riso-2026a","paper":"light","ops":[]}"#
        XCTAssertThrowsError(try DoodleCodec.decode(json: json)) { error in
            XCTAssertEqual(error as? DoodleCodecError, .unsupportedVersion(99))
        }
    }

    func testFillOpRoundTrip() throws {
        let document = DoodleDocument(ops: [.fill(ink: .coral, seedX: 12, seedY: 34)])
        let decoded = try DoodleCodec.decode(try DoodleCodec.encode(document))
        XCTAssertEqual(decoded, document)
    }

    func testPlanShapedJSONKeys() throws {
        let document = DoodleDocument(
            ops: [.stroke(tool: .pen, ink: .blue, points: [DoodlePoint(x: 1, y: 2, pressure: 0.5, tMs: 0)])]
        )
        let string = try DoodleCodec.encodeString(document)
        for key in ["\"v\"", "\"paletteId\"", "\"paper\"", "\"ops\"", "\"t\"", "\"tool\"", "\"ink\"", "\"pts\""] {
            XCTAssertTrue(string.contains(key), "Missing key \(key)")
        }
    }
}
