import Foundation

#if canImport(CoreGraphics)
import CoreGraphics

/// Core Graphics replay of doodle ops — used for thumbnails and Metal texture upload.
public enum CGStrokeRenderer: Sendable {
    public struct Options: Sendable {
        public var size: Int
        public var showsDotGrid: Bool
        public var dotSpacing: Double
        public var liveStroke: (tool: DrawingToolID, ink: InkID, points: [DoodlePoint])?

        public init(
            size: Int = Int(CanvasSpace.size),
            showsDotGrid: Bool = false,
            dotSpacing: Double = 32,
            liveStroke: (tool: DrawingToolID, ink: InkID, points: [DoodlePoint])? = nil
        ) {
            self.size = size
            self.showsDotGrid = showsDotGrid
            self.dotSpacing = dotSpacing
            self.liveStroke = liveStroke
        }
    }

    /// Render document (+ optional live stroke / dot grid) into a bitmap context.
    /// Caller owns the context; coordinate space is top-left origin in pixel units matching `options.size`.
    public static func draw(_ document: DoodleDocument, in context: CGContext, options: Options = Options()) {
        let pixelSize = CGFloat(options.size)
        let scale = pixelSize / CanvasSpace.size

        context.saveGState()
        context.setFillColor(RisoPalette.cgPaperColor(document.paper))
        context.fill(CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))

        if options.showsDotGrid {
            drawDotGrid(in: context, pixelSize: pixelSize, spacing: options.dotSpacing * scale)
        }

        context.scaleBy(x: scale, y: scale)

        for op in document.ops {
            draw(op: op, in: context)
        }

        if let live = options.liveStroke, !live.points.isEmpty {
            drawStroke(tool: live.tool, ink: live.ink, points: live.points, in: context)
        }

        context.restoreGState()
    }

    public enum BitmapFormat: Sendable {
        /// RGBA8888 — good for CGImage / PNG encode.
        case rgba
        /// BGRA8888 little-endian — matches Metal `.bgra8Unorm` drawables.
        case bgra
    }

    public static func makeBitmapContext(size: Int, format: BitmapFormat = .rgba) -> CGContext? {
        let bytesPerRow = size * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: UInt32
        switch format {
        case .rgba:
            bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        case .bgra:
            bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        }
        return CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
    }

    public static func makeImage(_ document: DoodleDocument, size: Int, showsDotGrid: Bool = false) -> CGImage? {
        guard let context = makeBitmapContext(size: size) else { return nil }
        // Flip to top-left origin for PNG consumers.
        context.translateBy(x: 0, y: CGFloat(size))
        context.scaleBy(x: 1, y: -1)
        draw(document, in: context, options: Options(size: size, showsDotGrid: showsDotGrid))
        return context.makeImage()
    }

    private static func draw(op: DoodleOp, in context: CGContext) {
        switch op {
        case let .stroke(tool, ink, points):
            drawStroke(tool: tool, ink: ink, points: points, in: context)
        case .fill:
            // S1b — no-op until fill lands; still round-trips in JSON.
            break
        }
    }

    private static func drawStroke(
        tool: DrawingToolID,
        ink: InkID,
        points: [DoodlePoint],
        in context: CGContext
    ) {
        guard !points.isEmpty else { return }
        let spec = DrawingToolSpec.spec(for: tool)
        let path = CGMutablePath()
        FreehandStroke.appendStrokePath(path, points: points)

        // Variable width approximated by average pressure for v1 (stable replay).
        let avgPressure = points.map(\.pressure).reduce(0, +) / Double(points.count)
        let width = spec.width(forPressure: avgPressure)

        context.saveGState()
        context.setStrokeColor(RisoPalette.cgColor(for: ink))
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        // Mid-opacity stacking: sourceOver lets inks overprint.
        context.setBlendMode(.normal)
        context.addPath(path)
        context.strokePath()
        context.restoreGState()
    }

    private static func drawDotGrid(in context: CGContext, pixelSize: CGFloat, spacing: CGFloat) {
        let spacing = max(spacing, 4)
        context.saveGState()
        let paperIsDark = false // grid contrast handled by alpha; light dots on both
        let alpha: CGFloat = paperIsDark ? 0.35 : 0.22
        context.setFillColor(CGColor(gray: 0.35, alpha: alpha))
        var y: CGFloat = spacing
        while y < pixelSize {
            var x: CGFloat = spacing
            while x < pixelSize {
                context.fillEllipse(in: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                x += spacing
            }
            y += spacing
        }
        context.restoreGState()
    }
}
#endif
