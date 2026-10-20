import Foundation
import Testing
@testable import HabitQuiltDomain

@Suite("PreservationRules")
struct PreservationTests {
    @Test("today's doodle is editable; yesterday is preserved")
    func editUntilEOD() throws {
        let tz = try #require(TimeZone(identifier: "America/New_York"))
        let now = date(year: 2026, month: 7, day: 4, hour: 18, minute: 0, tz: tz)
        let today = DayKey.today(now: now, timeZone: tz)
        let yesterday = DayKey(date: now.addingTimeInterval(-86_400), timeZone: tz)

        #expect(PreservationRules.editability(of: today, now: now, timeZone: tz) == .editable)
        #expect(PreservationRules.isEditable(day: today, now: now, timeZone: tz))
        #expect(PreservationRules.editability(of: yesterday, now: now, timeZone: tz) == .preserved)
        #expect(PreservationRules.isPreserved(day: yesterday, now: now, timeZone: tz))
    }

    @Test("future day keys are preserved (not editable)")
    func futureNotEditable() throws {
        let tz = try #require(TimeZone(identifier: "UTC"))
        let now = date(year: 2026, month: 1, day: 10, hour: 12, minute: 0, tz: tz)
        let tomorrow = try #require(DayKey.parse("2026-01-11"))
        #expect(PreservationRules.editability(of: tomorrow, now: now, timeZone: tz) == .preserved)
    }

    @Test("midnight auto-preserve keeps open session for the day that ended")
    func midnightAutoPreserveOpenSession() throws {
        let tz = try #require(TimeZone(identifier: "Europe/Paris"))
        // Just after local midnight on 2026-09-02
        let now = date(year: 2026, month: 9, day: 2, hour: 0, minute: 0, second: 1, tz: tz)
        let yesterday = try #require(DayKey.parse("2026-09-01"))

        let result = PreservationRules.evaluateMidnightCrossing(
            openSessionDay: yesterday,
            now: now,
            timeZone: tz
        )
        #expect(result.dayThatEnded.rawValue == "2026-09-01")
        #expect(result.shouldPreserveOpenSession)
    }

    @Test("midnight with no open session does not request preserve")
    func midnightNoSession() throws {
        let tz = try #require(TimeZone(identifier: "Europe/Paris"))
        let now = date(year: 2026, month: 9, day: 2, hour: 0, minute: 0, second: 1, tz: tz)

        let result = PreservationRules.evaluateMidnightCrossing(
            openSessionDay: nil,
            now: now,
            timeZone: tz
        )
        #expect(result.dayThatEnded.rawValue == "2026-09-01")
        #expect(!result.shouldPreserveOpenSession)
    }

    @Test("open session for a different day is not auto-preserved as yesterday")
    func openSessionWrongDay() throws {
        let tz = try #require(TimeZone(identifier: "UTC"))
        let now = date(year: 2026, month: 4, day: 2, hour: 0, minute: 0, second: 5, tz: tz)
        let older = try #require(DayKey.parse("2026-03-30"))

        let result = PreservationRules.evaluateMidnightCrossing(
            openSessionDay: older,
            now: now,
            timeZone: tz
        )
        #expect(result.dayThatEnded.rawValue == "2026-04-01")
        #expect(!result.shouldPreserveOpenSession)
    }

    @Test("DayRecord.preserve sets preservedAt once")
    func dayRecordPreserve() throws {
        let day = try #require(DayKey.parse("2026-05-01"))
        var record = DayRecord(day: day, habitID: UUID(), doodle: DoodleDocument())
        #expect(record.preservedAt == nil)
        let first = date(year: 2026, month: 5, day: 2, hour: 0, minute: 0, tz: .gmt)
        record.preserve(at: first)
        #expect(record.preservedAt == first)
        let later = first.addingTimeInterval(60)
        record.preserve(at: later)
        #expect(record.preservedAt == first) // stays first preserve moment
    }
}

private func date(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    second: Int = 0,
    tz: TimeZone
) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = tz
    var comps = DateComponents()
    comps.year = year
    comps.month = month
    comps.day = day
    comps.hour = hour
    comps.minute = minute
    comps.second = second
    return calendar.date(from: comps)!
}
