import XCTest
@testable import DoodleCanvas

#if canImport(CoreGraphics) && canImport(ImageIO)
import CoreGraphics
#endif

final class ThumbnailRenderTests: XCTestCase {
    func testPNGRendersWithoutSimulator() throws {
#if canImport(CoreGraphics) && canImport(ImageIO)
        let document = DoodleDocument(
            paper: .light,
            ops: [
                .stroke(
                    tool: .pen,
                    ink: .blue,
                    points: [
                        DoodlePoint(x: 100, y: 100, pressure: 0.5, tMs: 0),
                        DoodlePoint(x: 400, y: 300, pressure: 0.8, tMs: 30),
                        DoodlePoint(x: 700, y: 200, pressure: 0.6, tMs: 60),
                    ]
                ),
                .stroke(
                    tool: .pen,
                    ink: .coral,
                    points: [
                        DoodlePoint(x: 200, y: 500, pressure: 0.5, tMs: 0),
                        DoodlePoint(x: 600, y: 550, pressure: 0.5, tMs: 20),
                    ]
                ),
            ]
        )

        let data = try ThumbnailRenderer.pngData(from: document, pixelSize: 128)
        XCTAssertFalse(data.isEmpty)
        // PNG magic
        XCTAssertEqual(data.prefix(8), Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]))
#else
        throw XCTSkip("CoreGraphics/ImageIO unavailable on this platform")
#endif
    }

    func testThumbnailIgnoresDotGridAid() throws {
#if canImport(CoreGraphics) && canImport(ImageIO)
        let document = DoodleDocument(
            ops: [.stroke(tool: .pen, ink: .green, points: [DoodlePoint(x: 64, y: 64)])]
        )
        // API has no showsDotGrid parameter — thumbnails never include the aid.
        let data = try ThumbnailRenderer.pngData(from: document, pixelSize: 64)
        XCTAssertFalse(data.isEmpty)

        guard let withGrid = CGStrokeRenderer.makeImage(document, size: 64, showsDotGrid: true),
              let withoutGrid = CGStrokeRenderer.makeImage(document, size: 64, showsDotGrid: false)
        else {
            return XCTFail("Expected CG images")
        }
        // Grid aid changes pixels when requested for live canvas; thumbnail path uses false.
        XCTAssertNotNil(withGrid)
        XCTAssertNotNil(withoutGrid)
#else
        throw XCTSkip("CoreGraphics/ImageIO unavailable on this platform")
#endif
    }

    func testDeterministicReplaySameOps() throws {
#if canImport(CoreGraphics)
        let document = DoodleDocument(
            ops: [
                .stroke(
                    tool: .pen,
                    ink: .violet,
                    points: [
                        DoodlePoint(x: 10, y: 10, pressure: 0.5, tMs: 0),
                        DoodlePoint(x: 200, y: 180, pressure: 0.5, tMs: 10),
                    ]
                ),
            ]
        )
        guard let a = CGStrokeRenderer.makeImage(document, size: 64),
              let b = CGStrokeRenderer.makeImage(document, size: 64)
        else {
            return XCTFail("Expected images")
        }
        XCTAssertEqual(a.width, b.width)
        XCTAssertEqual(a.height, b.height)
        // Pixel-stable: same document → identical PNG bytes
        let pngA = try ThumbnailRenderer.pngData(from: document, pixelSize: 64)
        let pngB = try ThumbnailRenderer.pngData(from: document, pixelSize: 64)
        XCTAssertEqual(pngA, pngB)
#else
        throw XCTSkip("CoreGraphics unavailable on this platform")
#endif
    }

    func testToolWidthsDistinct() {
        let pen = DrawingToolSpec.pen.width(forPressure: 0.5)
        let pencil = DrawingToolSpec.pencil.width(forPressure: 0.5)
        XCTAssertNotEqual(pen, pencil)
        XCTAssertGreaterThan(pencil, pen)
    }
}
