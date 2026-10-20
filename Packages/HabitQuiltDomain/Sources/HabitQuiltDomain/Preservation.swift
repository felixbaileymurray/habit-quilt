import Foundation

/// Whether a doodle for a given day may still be edited.
///
/// Product language uses **preserved**, never "locked".
public enum DayEditability: Equatable, Sendable {
    /// The doodle (if any) may still be edited — the day is still "today".
    case editable
    /// The day has ended; the doodle is preserved as-is.
    case preserved
}

/// Pure rules for edit-until-EOD and midnight auto-preserve.
public enum PreservationRules: Sendable {
    /// A doodle day is editable while its key equals local today; afterwards it is preserved.
    public static func editability(
        of day: DayKey,
        now: Date = Date(),
        timeZone: TimeZone = .current
    ) -> DayEditability {
        let today = DayKey.today(now: now, timeZone: timeZone)
        return day == today ? .editable : .preserved
    }

    public static func isEditable(
        day: DayKey,
        now: Date = Date(),
        timeZone: TimeZone = .current
    ) -> Bool {
        editability(of: day, now: now, timeZone: timeZone) == .editable
    }

    public static func isPreserved(
        day: DayKey,
        now: Date = Date(),
        timeZone: TimeZone = .current
    ) -> Bool {
        editability(of: day, now: now, timeZone: timeZone) == .preserved
    }

    /// Result of checking an open doodle session at (or after) local midnight.
    public struct MidnightAutoPreserve: Equatable, Sendable {
        /// The day that just ended and should be preserved as-is.
        public let dayThatEnded: DayKey
        /// True when an open session for that day must be auto-preserved now.
        public let shouldPreserveOpenSession: Bool

        public init(dayThatEnded: DayKey, shouldPreserveOpenSession: Bool) {
            self.dayThatEnded = dayThatEnded
            self.shouldPreserveOpenSession = shouldPreserveOpenSession
        }
    }

    /// If a doodle session is still open at local midnight, auto-preserve it as it is
    /// for the day that just ended. The new calendar day starts with no open session
    /// for yesterday's tile.
    ///
    /// - Parameters:
    ///   - openSessionDay: The day key of the doodle currently being edited, if any.
    ///   - previousLocalDay: The local calendar day that just ended (caller's responsibility
    ///     to compute from the midnight crossing).
    ///   - now: Current instant (typically just after the midnight tick).
    ///   - timeZone: Device local time zone.
    public static func midnightAutoPreserve(
        openSessionDay: DayKey?,
        previousLocalDay: DayKey,
        now: Date = Date(),
        timeZone: TimeZone = .current
    ) -> MidnightAutoPreserve {
        let shouldPreserve: Bool
        if let open = openSessionDay {
            // Preserve when the open session belongs to the day that ended
            // (still open past that day's EOD). Compare by calendar day key.
            shouldPreserve = open.rawValue == previousLocalDay.rawValue
        } else {
            shouldPreserve = false
        }

        return MidnightAutoPreserve(
            dayThatEnded: previousLocalDay,
            shouldPreserveOpenSession: shouldPreserve
        )
    }

    /// Convenience: given `now` just after a local midnight crossing, derive the day that
    /// ended and decide whether to auto-preserve `openSessionDay`.
    public static func evaluateMidnightCrossing(
        openSessionDay: DayKey?,
        now: Date,
        timeZone: TimeZone
    ) -> MidnightAutoPreserve {
        let today = DayKey.today(now: now, timeZone: timeZone)
        guard let todayStart = today.startOfDay(in: timeZone) else {
            return MidnightAutoPreserve(dayThatEnded: today, shouldPreserveOpenSession: false)
        }
        // One second before today's start is still yesterday in local calendar terms.
        let justBefore = todayStart.addingTimeInterval(-1)
        let previous = DayKey(date: justBefore, timeZone: timeZone)
        return midnightAutoPreserve(
            openSessionDay: openSessionDay,
            previousLocalDay: previous,
            now: now,
            timeZone: timeZone
        )
    }
}
