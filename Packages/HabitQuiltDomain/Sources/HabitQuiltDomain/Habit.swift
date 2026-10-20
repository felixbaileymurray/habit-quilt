import Foundation

/// The single active habit for MVP. Rename in place; quilt / history continue under the new label.
public struct Habit: Hashable, Sendable, Codable, Identifiable {
    public let id: UUID
    public var name: String
    public let createdAt: Date
    public var archivedAt: Date?

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.archivedAt = archivedAt
    }

    /// Renames the habit in place. Identity (`id`) and history stay the same —
    /// the quilt is not reset.
    public mutating func rename(to newName: String) {
        name = newName
    }

    /// Non-mutating rename that returns a copy with the new name and the same `id`.
    public func renamed(to newName: String) -> Habit {
        var copy = self
        copy.rename(to: newName)
        return copy
    }
}

/// A day's quilt tile record. Blank days simply have no doodle (no record, or `doodle == nil`).
public struct DayRecord: Hashable, Sendable, Codable, Identifiable {
    public var id: String { day.rawValue }

    public let day: DayKey
    public let habitID: UUID
    public var doodle: DoodleDocument?
    /// Derived cache path; not part of the portable doodle document.
    public var thumbPath: String?
    public let createdAt: Date
    public var updatedAt: Date
    /// Set when the doodle becomes preserved (EOD or midnight auto-preserve).
    public var preservedAt: Date?
    /// Reserved for onboarding example tile (v2); unused in MVP logic.
    public var isExample: Bool

    public init(
        day: DayKey,
        habitID: UUID,
        doodle: DoodleDocument? = nil,
        thumbPath: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        preservedAt: Date? = nil,
        isExample: Bool = false
    ) {
        self.day = day
        self.habitID = habitID
        self.doodle = doodle
        self.thumbPath = thumbPath
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.preservedAt = preservedAt
        self.isExample = isExample
    }

    public var hasDoodle: Bool { doodle != nil }

    /// Marks the day preserved at `at`, keeping the doodle content as-is.
    public mutating func preserve(at date: Date = Date()) {
        if preservedAt == nil {
            preservedAt = date
        }
        updatedAt = date
    }
}
