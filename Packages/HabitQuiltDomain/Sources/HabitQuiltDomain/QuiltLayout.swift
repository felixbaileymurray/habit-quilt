import Foundation

/// Discrete pinch-zoom column counts (Apple Photos–style snaps).
public enum QuiltColumnCount: Int, Hashable, Sendable, Codable, CaseIterable, Comparable {
    case one = 1
    case two = 2
    case three = 3
    case five = 5
    case seven = 7
    case ten = 10
    case fifteen = 15
    case twenty = 20

    public static func < (lhs: QuiltColumnCount, rhs: QuiltColumnCount) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public static let snaps: [QuiltColumnCount] = QuiltColumnCount.allCases.sorted()
}

/// A single cell in the quilt grid.
public struct QuiltTile: Hashable, Sendable, Identifiable {
    public var id: String { day.rawValue }
    public let day: DayKey
    /// `nil` means a blank (no doodle) day.
    public let dayRecord: DayRecord?
    public let row: Int
    public let column: Int
    public let index: Int

    public var isBlank: Bool { dayRecord?.hasDoodle != true }

    public init(day: DayKey, dayRecord: DayRecord?, row: Int, column: Int, index: Int) {
        self.day = day
        self.dayRecord = dayRecord
        self.row = row
        self.column = column
        self.index = index
    }
}

/// Quilt layout maths: oldest at top, newest at bottom; fill top-left;
/// complete each horizontal row left → right (Apple Photos–style, not weekday-aligned).
public enum QuiltLayout: Sendable {
    /// Builds tiles for the inclusive range `[start, end]`, ordered oldest → newest.
    ///
    /// - Parameters:
    ///   - start: Habit start (or first day to show).
    ///   - end: Typically today.
    ///   - recordsByDay: Map of `DayKey.rawValue` → record (completed days).
    ///   - columns: Column count for row/column assignment.
    ///   - hideBlanks: When true, blank days are omitted (completed-only filter).
    public static func tiles(
        from start: DayKey,
        through end: DayKey,
        recordsByDay: [String: DayRecord],
        columns: QuiltColumnCount,
        hideBlanks: Bool = false
    ) -> [QuiltTile] {
        let days = DayKey.days(from: start, through: end)
        let filtered: [DayKey]
        if hideBlanks {
            filtered = days.filter { recordsByDay[$0.rawValue]?.hasDoodle == true }
        } else {
            filtered = days
        }
        return layout(days: filtered, recordsByDay: recordsByDay, columns: columns)
    }

    /// Filters a day sequence to completed (non-blank) days only.
    public static func hideBlanks(
        days: [DayKey],
        recordsByDay: [String: DayRecord]
    ) -> [DayKey] {
        days.filter { recordsByDay[$0.rawValue]?.hasDoodle == true }
    }

    /// Filters existing tiles to non-blank ones, then re-lays out with the same column count.
    public static func applyingHideBlanks(
        to tiles: [QuiltTile],
        columns: QuiltColumnCount
    ) -> [QuiltTile] {
        let kept = tiles.filter { !$0.isBlank }.map(\.day)
        let records = Dictionary(
            uniqueKeysWithValues: tiles.compactMap { tile -> (String, DayRecord)? in
                guard let record = tile.dayRecord else { return nil }
                return (tile.day.rawValue, record)
            }
        )
        return layout(days: kept, recordsByDay: records, columns: columns)
    }

    /// Row/column for a linear index with top-left origin and row-major fill.
    public static func position(index: Int, columns: QuiltColumnCount) -> (row: Int, column: Int) {
        let cols = columns.rawValue
        precondition(cols > 0)
        return (row: index / cols, column: index % cols)
    }

    /// Number of rows needed for `tileCount` tiles at `columns`.
    public static func rowCount(tileCount: Int, columns: QuiltColumnCount) -> Int {
        guard tileCount > 0 else { return 0 }
        let cols = columns.rawValue
        return (tileCount + cols - 1) / cols
    }

    private static func layout(
        days: [DayKey],
        recordsByDay: [String: DayRecord],
        columns: QuiltColumnCount
    ) -> [QuiltTile] {
        days.enumerated().map { index, day in
            let pos = position(index: index, columns: columns)
            return QuiltTile(
                day: day,
                dayRecord: recordsByDay[day.rawValue],
                row: pos.row,
                column: pos.column,
                index: index
            )
        }
    }
}
