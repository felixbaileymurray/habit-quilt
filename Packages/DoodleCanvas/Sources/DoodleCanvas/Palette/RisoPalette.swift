import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

/// Provisional riso-inspired palette (plan §2.13 / §3.1). Mid-opacity inks that stack.
public enum RisoPalette: Sendable {
    public static let id = "riso-2026a"

    /// Mid opacity (~0.55) so overlapping strokes overprint like riso inks.
    public static let inkOpacity: Double = 0.55

    public struct RGBA: Hashable, Sendable {
        public var r: Double
        public var g: Double
        public var b: Double
        public var a: Double

        public init(r: Double, g: Double, b: Double, a: Double) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
    }

    public static func color(for ink: InkID) -> RGBA {
        let a = inkOpacity
        switch ink {
        case .coral: return RGBA(r: 0.92, g: 0.38, b: 0.42, a: a)
        case .orange: return RGBA(r: 0.95, g: 0.55, b: 0.22, a: a)
        case .yellow: return RGBA(r: 0.93, g: 0.82, b: 0.20, a: a)
        case .green: return RGBA(r: 0.28, g: 0.72, b: 0.40, a: a)
        case .teal: return RGBA(r: 0.18, g: 0.62, b: 0.68, a: a)
        case .blue: return RGBA(r: 0.22, g: 0.42, b: 0.86, a: a)
        case .violet: return RGBA(r: 0.52, g: 0.32, b: 0.78, a: a)
        case .burgundy: return RGBA(r: 0.62, g: 0.18, b: 0.32, a: a)
        }
    }

    public static func paperColor(_ paper: PaperKind) -> RGBA {
        switch paper {
        case .light: return RGBA(r: 0.97, g: 0.95, b: 0.90, a: 1)
        case .dark: return RGBA(r: 0.14, g: 0.13, b: 0.12, a: 1)
        }
    }

    public static var allInks: [InkID] { InkID.allCases }

#if canImport(CoreGraphics)
    public static func cgColor(for ink: InkID) -> CGColor {
        let c = color(for: ink)
        return CGColor(red: c.r, green: c.g, blue: c.b, alpha: c.a)
    }

    public static func cgPaperColor(_ paper: PaperKind) -> CGColor {
        let c = paperColor(paper)
        return CGColor(red: c.r, green: c.g, blue: c.b, alpha: c.a)
    }
#endif
}
