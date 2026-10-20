import Foundation

/// Curated riso ink identifiers — stored in doodle JSON, never as hex.
public enum InkID: String, Codable, Hashable, Sendable, CaseIterable {
    case coral
    case orange
    case yellow
    case green
    case teal
    case blue
    case violet
    case burgundy
}

/// Drawing surface paper — part of the doodle document, not an app dark theme.
public enum PaperKind: String, Codable, Hashable, Sendable, CaseIterable {
    case light
    case dark
}
