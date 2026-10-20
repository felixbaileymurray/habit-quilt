/// Public surface placeholder for Habit Quilt domain logic.
/// Sibling workers own day preservation, quilt layout, and doodle JSON.
/// The app scaffolds against these types; replace stubs during package implementation.

import Foundation

/// Local calendar day key (`YYYY-MM-DD`) plus UTC offset captured at entry.
public struct LocalDayKey: Hashable, Sendable, Codable {
    public let dateString: String
    public let utcOffsetMinutes: Int

    public init(dateString: String, utcOffsetMinutes: Int) {
        self.dateString = dateString
        self.utcOffsetMinutes = utcOffsetMinutes
    }
}

/// Whether a day's doodle may still be edited.
public enum DayEditability: Sendable, Equatable {
    case editable
    case preserved
}

/// Protocol the app uses until domain package fills in real rules.
public protocol DayPreservationRules: Sendable {
    /// A doodle is editable while `dayDate == today` in the device calendar; preserved after.
    func editability(dayDate: String, today: String) -> DayEditability

    /// If a session is open at local midnight, auto-preserve for the day that just ended.
    func shouldAutoPreserveAtMidnight(
        openSessionDay: String,
        previousCalendarDay: String,
        newCalendarDay: String
    ) -> Bool
}

/// Minimal default used by the app scaffold and unit tests.
/// TODO(domain): move authoritative rules into HabitQuiltDomain and delete app-local duplicates.
public struct DefaultDayPreservationRules: DayPreservationRules {
    public init() {}

    public func editability(dayDate: String, today: String) -> DayEditability {
        dayDate == today ? .editable : .preserved
    }

    public func shouldAutoPreserveAtMidnight(
        openSessionDay: String,
        previousCalendarDay: String,
        newCalendarDay: String
    ) -> Bool {
        openSessionDay == previousCalendarDay && newCalendarDay != previousCalendarDay
    }
}

/// Versioned doodle document placeholder (portable JSON; no PencilKit).
/// TODO(domain): implement encode/decode + schema migrations.
public struct DoodleDocument: Codable, Sendable, Equatable {
    public var v: Int
    public var paletteId: String
    public var paper: String
    public var ops: [DoodleOp]

    public init(
        v: Int = 1,
        paletteId: String = "riso-2026a",
        paper: String = "light",
        ops: [DoodleOp] = []
    ) {
        self.v = v
        self.paletteId = paletteId
        self.paper = paper
        self.ops = ops
    }
}

public struct DoodleOp: Codable, Sendable, Equatable {
    public var t: String
    public var tool: String?
    public var ink: String?
    public var pts: [[Double]]?
    public var seed: [Double]?

    public init(
        t: String,
        tool: String? = nil,
        ink: String? = nil,
        pts: [[Double]]? = nil,
        seed: [Double]? = nil
    ) {
        self.t = t
        self.tool = tool
        self.ink = ink
        self.pts = pts
        self.seed = seed
    }
}

/// Quilt layout maths placeholder.
/// TODO(domain): oldest-top, top-left row fill, blank filtering, column snaps.
public enum QuiltLayout {
    public static func columnCounts() -> [Int] {
        [1, 2, 3, 5, 7, 10, 15, 20]
    }
}
