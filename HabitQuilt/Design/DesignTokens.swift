import SwiftUI

/// Typed design tokens for Habit Quilt chrome and drawing surfaces.
/// Views must use token keys — no ad-hoc colours.
enum DesignTokens {
    // MARK: - Paper UI (app chrome — light only)

    enum PaperUI {
        static let background = Color(red: 0.98, green: 0.97, blue: 0.94)
        static let surface = Color(red: 1.0, green: 0.99, blue: 0.97)
        static let border = Color(red: 0.86, green: 0.84, blue: 0.80)
        static let textPrimary = Color(red: 0.16, green: 0.14, blue: 0.12)
        static let textSecondary = Color(red: 0.42, green: 0.40, blue: 0.36)
        static let draftHighlight = Color(red: 1.0, green: 0.92, blue: 0.45).opacity(0.55)
        static let accent = Color(red: 0.18, green: 0.42, blue: 0.55)
        static let destructive = Color(red: 0.72, green: 0.22, blue: 0.18)
    }

    // MARK: - Drawing paper (canvas surfaces, not app dark mode)

    enum DrawingPaper: String, CaseIterable, Identifiable {
        case light
        case dark

        var id: String { rawValue }

        var color: Color {
            switch self {
            case .light: Color(red: 0.96, green: 0.94, blue: 0.90)
            case .dark: Color(red: 0.18, green: 0.17, blue: 0.16)
            }
        }
    }

    // MARK: - Riso inks (palette IDs → Color; mid opacity for stacking)

    enum RisoInk: String, CaseIterable, Identifiable {
        case red, orange, yellow, green, blue, violet, brown, black

        var id: String { rawValue }

        /// Display / preview colour at mid opacity (~0.55).
        var color: Color {
            switch self {
            case .red: Color(red: 0.86, green: 0.22, blue: 0.24).opacity(0.55)
            case .orange: Color(red: 0.92, green: 0.48, blue: 0.18).opacity(0.55)
            case .yellow: Color(red: 0.95, green: 0.82, blue: 0.20).opacity(0.55)
            case .green: Color(red: 0.28, green: 0.62, blue: 0.38).opacity(0.55)
            case .blue: Color(red: 0.22, green: 0.42, blue: 0.78).opacity(0.55)
            case .violet: Color(red: 0.52, green: 0.30, blue: 0.70).opacity(0.55)
            case .brown: Color(red: 0.55, green: 0.36, blue: 0.24).opacity(0.55)
            case .black: Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.55)
            }
        }
    }

    // MARK: - Spacing

    enum Space {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radii

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 16
    }

    // MARK: - Typography

    enum TypeScale {
        static let title = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let headline = Font.system(.title2, design: .rounded).weight(.semibold)
        static let body = Font.system(.body, design: .rounded)
        static let callout = Font.system(.callout, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
    }
}
