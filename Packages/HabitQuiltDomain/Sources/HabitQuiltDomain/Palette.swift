import Foundation

/// Drawing surface paper. These are canvas backgrounds, not an app dark theme.
public enum PaperID: String, Hashable, Sendable, Codable, CaseIterable {
    case light
    case dark
}

/// Mid-opacity riso ink identifiers. Stored in doodle JSON; never hex.
public enum InkID: String, Hashable, Sendable, Codable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case teal
    case blue
    case violet
    case black
}

/// Normalized RGBA in 0...1. Pure domain — no UIKit / SwiftUI dependency.
public struct RGBAColor: Hashable, Sendable, Codable {
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

/// Versioned provisional palette: 2 papers + 8 mid-opacity riso inks.
///
/// Preserved doodles keep their `paletteId` so colours stay stable if the
/// live palette changes later.
public struct Palette: Hashable, Sendable, Codable {
    public let id: String
    public let papers: [PaperID: RGBAColor]
    public let inks: [InkID: RGBAColor]

    public init(id: String, papers: [PaperID: RGBAColor], inks: [InkID: RGBAColor]) {
        self.id = id
        self.papers = papers
        self.inks = inks
    }

    public func paperColor(_ id: PaperID) -> RGBAColor? { papers[id] }
    public func inkColor(_ id: InkID) -> RGBAColor? { inks[id] }

    /// Provisional MVP palette (`riso-2026a`). Expected to change.
    public static let riso2026a: Palette = {
        // Mid-opacity (~0.72) so stacked inks overprint like riso.
        let mid = 0.72
        return Palette(
            id: "riso-2026a",
            papers: [
                .light: RGBAColor(r: 0.98, g: 0.97, b: 0.94, a: 1.0),
                .dark: RGBAColor(r: 0.12, g: 0.11, b: 0.10, a: 1.0),
            ],
            inks: [
                .red: RGBAColor(r: 0.86, g: 0.20, b: 0.22, a: mid),
                .orange: RGBAColor(r: 0.92, g: 0.45, b: 0.12, a: mid),
                .yellow: RGBAColor(r: 0.95, g: 0.82, b: 0.18, a: mid),
                .green: RGBAColor(r: 0.22, g: 0.62, b: 0.32, a: mid),
                .teal: RGBAColor(r: 0.12, g: 0.55, b: 0.58, a: mid),
                .blue: RGBAColor(r: 0.18, g: 0.35, b: 0.78, a: mid),
                .violet: RGBAColor(r: 0.48, g: 0.22, b: 0.68, a: mid),
                .black: RGBAColor(r: 0.08, g: 0.08, b: 0.08, a: mid),
            ]
        )
    }()

    public static let currentProvisional: Palette = .riso2026a

    public static func resolve(id: String) -> Palette? {
        switch id {
        case riso2026a.id: return .riso2026a
        default: return nil
        }
    }
}
