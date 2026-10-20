import SwiftUI

/// Semantic app icons. Rendering currently uses Lucide placeholders
/// (`LucidePlaceholderPaths` + `Design/Icons/Lucide/*.svg`).
/// Replace that pack with hand-drawn SVGs later — keep these cases stable.
enum HQIcon: String, CaseIterable, Identifiable {
    case settings
    case chevronRight
    case close
    case undo
    case redo
    case pen
    case pencil
    case clear
    case grid

    var id: String { rawValue }

    /// Lucide filename stem (for the temporary SVG sources on disk).
    var lucideFileStem: String {
        switch self {
        case .settings: "settings"
        case .chevronRight: "chevron-right"
        case .close: "x"
        case .undo: "undo-2"
        case .redo: "redo-2"
        case .pen: "pen"
        case .pencil: "pencil"
        case .clear: "eraser"
        case .grid: "grid-3x3"
        }
    }
}
