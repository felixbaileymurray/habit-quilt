import XCTest
@testable import DoodleCanvas

@MainActor
final class DoodleSessionTests: XCTestCase {
    func testStrokeCommitAndUndoRedo() {
        let session = DoodleSession()
        session.selectedTool = .pen
        session.selectedInk = .green

        session.beginStroke(at: DoodlePoint(x: 100, y: 100, pressure: 0.5))
        session.appendStroke(point: DoodlePoint(x: 150, y: 160, pressure: 0.7))
        let op = session.endStroke()
        XCTAssertNotNil(op)
        XCTAssertEqual(session.document.ops.count, 1)
        XCTAssertTrue(session.canUndo)
        XCTAssertFalse(session.canRedo)

        session.undo()
        XCTAssertTrue(session.document.ops.isEmpty)
        XCTAssertTrue(session.canRedo)

        session.redo()
        XCTAssertEqual(session.document.ops.count, 1)
    }

    func testClearIsUndoable() {
        let session = DoodleSession()
        session.beginStroke(at: DoodlePoint(x: 10, y: 10))
        session.endStroke()
        session.beginStroke(at: DoodlePoint(x: 20, y: 20))
        session.endStroke()
        XCTAssertEqual(session.document.ops.count, 2)

        session.clear()
        XCTAssertTrue(session.document.isEmpty)
        session.undo()
        XCTAssertEqual(session.document.ops.count, 2)
    }

    func testPencilStubCanBeSelected() {
        let session = DoodleSession(selectedTool: .pencil, selectedInk: .violet)
        XCTAssertEqual(session.selectedTool, .pencil)
        XCTAssertTrue(DrawingToolSpec.pencil.isStub)
        session.beginStroke(at: DoodlePoint(x: 50, y: 50))
        session.endStroke()
        if case let .stroke(tool, _, _) = session.document.ops[0] {
            XCTAssertEqual(tool, .pencil)
        } else {
            XCTFail("Expected pencil stroke")
        }
    }

    func testDotGridToggleDoesNotEnterDocument() throws {
        let session = DoodleSession(ui: DoodleSessionUIState(showsDotGrid: true))
        session.beginStroke(at: DoodlePoint(x: 1, y: 1))
        session.endStroke()
        let data = try DoodleCodec.encode(session.document)
        XCTAssertTrue(DoodleCodec.serializedJSONOmitsDotGrid(data))
        XCTAssertTrue(session.ui.showsDotGrid)
    }

    func testPointsAreClampedToCanvas() {
        let session = DoodleSession()
        session.beginStroke(at: DoodlePoint(x: -50, y: 2000, pressure: 2))
        session.endStroke()
        if case let .stroke(_, _, points) = session.document.ops[0] {
            XCTAssertEqual(points[0].x, 0)
            XCTAssertEqual(points[0].y, CanvasSpace.size)
            XCTAssertEqual(points[0].pressure, 1)
        } else {
            XCTFail("Expected stroke")
        }
    }

    func testEightInksAndTwoPapers() {
        XCTAssertEqual(InkID.allCases.count, 8)
        XCTAssertEqual(PaperKind.allCases.count, 2)
        XCTAssertEqual(RisoPalette.allInks.count, 8)
        for ink in InkID.allCases {
            XCTAssertEqual(RisoPalette.color(for: ink).a, RisoPalette.inkOpacity, accuracy: 0.001)
        }
    }
}
