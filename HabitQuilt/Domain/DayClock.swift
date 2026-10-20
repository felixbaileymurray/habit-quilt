import Foundation
import HabitQuiltDomain

/// Calendar helpers for local-day keys and midnight auto-preserve.
struct DayClock: Sendable {
    var calendar: Calendar
    var timeZone: TimeZone
    var rules: any DayPreservationRules

    init(
        calendar: Calendar = .current,
        timeZone: TimeZone = .current,
        rules: any DayPreservationRules = DefaultDayPreservationRules()
    ) {
        var cal = calendar
        cal.timeZone = timeZone
        self.calendar = cal
        self.timeZone = timeZone
        self.rules = rules
    }

    /// Local calendar date string `YYYY-MM-DD`.
    func localDateString(for date: Date = Date()) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        let d = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    func utcOffsetMinutes(for date: Date = Date()) -> Int {
        timeZone.secondsFromGMT(for: date) / 60
    }

    func makeDayKey(for date: Date = Date()) -> LocalDayKey {
        LocalDayKey(
            dateString: localDateString(for: date),
            utcOffsetMinutes: utcOffsetMinutes(for: date)
        )
    }

    func editability(of dayDate: String, relativeTo now: Date = Date()) -> DayEditability {
        rules.editability(dayDate: dayDate, today: localDateString(for: now))
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
        let previousDay = localDateString(for: previousNow)
        let newDay = localDateString(for: newNow)
        guard rules.shouldAutoPreserveAtMidnight(
            openSessionDay: openSessionDay,
            previousCalendarDay: previousDay,
            newCalendarDay: newDay
        ) else {
            return nil
        }
        return openSessionDay
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
