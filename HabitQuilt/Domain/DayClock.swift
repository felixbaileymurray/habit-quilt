import Foundation
import HabitQuiltDomain

/// Calendar helpers for local-day keys and midnight auto-preserve.
/// Uses HabitQuiltDomain `DayKey` + `PreservationRules` as the authority.
struct DayClock: Sendable {
    var calendar: Calendar
    var timeZone: TimeZone

    init(
        calendar: Calendar = .current,
        timeZone: TimeZone = .current
    ) {
        var cal = calendar
        cal.timeZone = timeZone
        self.calendar = cal
        self.timeZone = timeZone
    }

    /// Local calendar date string `YYYY-MM-DD`.
    func localDateString(for date: Date = Date()) -> String {
        DayKey(date: date, timeZone: timeZone).rawValue
    }

    func utcOffsetSeconds(for date: Date = Date()) -> Int {
        timeZone.secondsFromGMT(for: date)
    }

    func makeDayKey(for date: Date = Date()) -> DayKey {
        DayKey(date: date, timeZone: timeZone)
    }

    func editability(of dayDate: String, relativeTo now: Date = Date()) -> DayEditability {
        guard let day = DayKey.parse(dayDate, utcOffsetSeconds: utcOffsetSeconds(for: now)) else {
            return .preserved
        }
        return PreservationRules.editability(of: day, now: now, timeZone: timeZone)
    }

    /// Start of the next local calendar day after `date`.
    func nextLocalMidnight(after date: Date = Date()) -> Date {
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
    }

    /// If an open doodle session crosses local midnight, return the day that should be preserved.
    func dayToAutoPreserveIfCrossingMidnight(
        openSessionDay: String,
        from previousNow: Date,
        to newNow: Date
    ) -> String? {
        let previousDay = DayKey(date: previousNow, timeZone: timeZone)
        let newDay = DayKey(date: newNow, timeZone: timeZone)
        guard previousDay.rawValue != newDay.rawValue else { return nil }

        let openKey = DayKey.parse(
            openSessionDay,
            utcOffsetSeconds: utcOffsetSeconds(for: previousNow)
        )
        let result = PreservationRules.midnightAutoPreserve(
            openSessionDay: openKey,
            previousLocalDay: previousDay,
            now: newNow,
            timeZone: timeZone
        )
        return result.shouldPreserveOpenSession ? result.dayThatEnded.rawValue : nil
    }
}

/// Coordinates repository writes when a day must be preserved.
@MainActor
final class DayPreservationCoordinator {
    private let repository: HabitRepositoryProtocol
    private let clock: DayClock

    init(repository: HabitRepositoryProtocol, clock: DayClock = DayClock()) {
        self.repository = repository
        self.clock = clock
    }

    /// Preserve a day if it is still editable and the calendar day has ended.
    @discardableResult
    func preserveIfNeeded(dayDate: String, now: Date = Date()) throws -> Bool {
        guard clock.editability(of: dayDate, relativeTo: now) == .preserved else {
            return false
        }
        guard let existing = try repository.fetchDay(date: dayDate), existing.preservedAt == nil else {
            return false
        }
        try repository.markPreserved(date: dayDate, at: now)
        return true
    }

    /// Midnight rule: auto-preserve an open session for the day that just ended.
    @discardableResult
    func autoPreserveOpenSessionIfMidnightPassed(
        openSessionDay: String?,
        from previousNow: Date,
        to newNow: Date
    ) throws -> Bool {
        guard let openSessionDay else { return false }
        guard let day = clock.dayToAutoPreserveIfCrossingMidnight(
            openSessionDay: openSessionDay,
            from: previousNow,
            to: newNow
        ) else {
            return false
        }
        if try repository.fetchDay(date: day) == nil {
            return false
        }
        try repository.markPreserved(date: day, at: newNow)
        return true
    }
}
