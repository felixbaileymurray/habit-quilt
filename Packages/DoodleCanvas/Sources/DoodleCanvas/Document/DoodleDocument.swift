import Foundation

/// Portable vector doodle document — source of truth for re-render and backup.
public struct DoodleDocument: Codable, Hashable, Sendable {
    public static let currentVersion = 1
    public static let defaultPaletteID = RisoPalette.id

    public var v: Int
    public var paletteId: String
    public var paper: PaperKind
    public var ops: [DoodleOp]

    public init(
        v: Int = Self.currentVersion,
        paletteId: String = Self.defaultPaletteID,
        paper: PaperKind = .light,
        ops: [DoodleOp] = []
    ) {
        self.v = v
        self.paletteId = paletteId
        self.paper = paper
        self.ops = ops
    }

    public var isEmpty: Bool { ops.isEmpty }
}

/// Session-only UI preferences that must never appear in doodle JSON.
public struct DoodleSessionUIState: Hashable, Sendable {
    public var showsDotGrid: Bool

    public init(showsDotGrid: Bool = false) {
        self.showsDotGrid = showsDotGrid
    }
}
