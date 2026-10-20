import Foundation

struct HabitRecord: Equatable, Identifiable, Sendable {
    var id: String
    var name: String
    var createdAt: Date
    var archivedAt: Date?
}

struct DayRecord: Equatable, Identifiable, Sendable {
    /// Local calendar date `YYYY-MM-DD` (primary key).
    var date: String
    var habitId: String
    var doodleJSON: String?
    var thumbPath: String?
    var createdAt: Date
    var updatedAt: Date
    /// Non-nil once the doodle is preserved (EOD or midnight auto-preserve).
    var preservedAt: Date?
    var isExample: Bool

    var id: String { date }

    var isPreserved: Bool { preservedAt != nil }
}

enum SettingsKey: String, Sendable {
    case hideBlankDays = "hide_blank_days"
    /// UI preference for doodle session default — not part of doodle documents.
    case dotGridDefault = "dot_grid_default"
    case lastBackupAt = "last_backup_at"
}
