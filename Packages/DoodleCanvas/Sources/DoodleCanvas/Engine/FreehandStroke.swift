import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Deterministic freehand outline: same points → same path on re-render.
public enum FreehandStroke: Sendable {
    /// Build a smoothed polyline width envelope for stroke replay.
    public static func widths(for points: [DoodlePoint], tool: DrawingToolSpec) -> [Double] {
        points.map { tool.width(forPressure: $0.pressure) }
    }

#if canImport(CoreGraphics)
    /// Append a rounded polyline path in normalized coordinates.
    public static func appendStrokePath(
        _ path: CGMutablePath,
        points: [DoodlePoint]
    ) {
        guard let first = points.first else { return }
        path.move(to: CGPoint(x: first.x, y: first.y))
        if points.count == 1 {
            // Degenerate tap: tiny segment so a round line-cap draws a dot.
            path.addLine(to: CGPoint(x: first.x + 0.01, y: first.y))
            return
        }
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }
    }
#endif
}
