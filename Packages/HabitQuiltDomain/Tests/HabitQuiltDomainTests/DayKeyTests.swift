import Foundation
import Testing
@testable import HabitQuiltDomain

@Suite("DayKey")
struct DayKeyTests {
    @Test("formats YYYY-MM-DD in the given time zone")
    func formatsLocalDate() throws {
        // 2026-03-15 15:00 UTC → still 15th in New York (EDT, UTC-4) and London (UTC)
        let instant = date(year: 2026, month: 3, day: 15, hour: 15, minute: 0, tz: .gmt)
        let ny = try #require(TimeZone(identifier: "America/New_York"))
        let key = DayKey(date: instant, timeZone: ny)
        #expect(key.rawValue == "2026-03-15")
        #expect(key.utcOffsetSeconds == ny.secondsFromGMT(for: instant))
    }

    @Test("crosses local midnight correctly near UTC day boundary")
    func localMidnightBoundary() throws {
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        // 2026-06-01 00:30 JST = 2026-05-31 15:30 UTC
        let justAfterLocalMidnight = date(
            year: 2026, month: 6, day: 1, hour: 0, minute: 30, tz: tokyo
        )
        let key = DayKey(date: justAfterLocalMidnight, timeZone: tokyo)
        #expect(key.rawValue == "2026-06-01")

        // 2026-05-31 23:30 JST
        let justBefore = date(year: 2026, month: 5, day: 31, hour: 23, minute: 30, tz: tokyo)
        #expect(DayKey(date: justBefore, timeZone: tokyo).rawValue == "2026-05-31")
    }

    @Test("today matches calendar day in time zone")
    func todayHelper() throws {
        let tz = try #require(TimeZone(identifier: "Europe/London"))
        let now = date(year: 2026, month: 10, day: 20, hour: 9, minute: 0, tz: tz)
        #expect(DayKey.today(now: now, timeZone: tz).rawValue == "2026-10-20")
    }

    @Test("parse accepts valid keys and rejects garbage")
    func parse() {
        #expect(DayKey.parse("2026-01-09")?.rawValue == "2026-01-09")
        #expect(DayKey.parse("2026-1-9") == nil)
        #expect(DayKey.parse("not-a-date") == nil)
        #expect(DayKey.parse("2026-13-01") == nil)
    }

    @Test("days(from:through:) is inclusive and oldest-first")
    func dayRange() throws {
        let start = try #require(DayKey.parse("2026-01-30"))
        let end = try #require(DayKey.parse("2026-02-02"))
        let days = DayKey.days(from: start, through: end).map(\.rawValue)
        #expect(days == ["2026-01-30", "2026-01-31", "2026-02-01", "2026-02-02"])
    }

    @Test("endOfDay is start of next local day")
    func endOfDay() throws {
        let tz = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let day = try #require(DayKey.parse("2026-03-08", utcOffsetSeconds: tz.secondsFromGMT()))
        let end = try #require(day.endOfDay(in: tz))
        #expect(DayKey(date: end, timeZone: tz).rawValue == "2026-03-09")
        // One second before end is still the same day
        #expect(DayKey(date: end.addingTimeInterval(-1), timeZone: tz).rawValue == "2026-03-08")
    }

    @Test("comparable by string key")
    func comparable() throws {
        let a = try #require(DayKey.parse("2026-01-01"))
        let b = try #require(DayKey.parse("2026-01-02"))
        #expect(a < b)
    }
}

// MARK: - Helpers

func date(
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
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
    comps.second = 0
    return calendar.date(from: comps)!
}

extension TimeZone {
    static var gmt: TimeZone { TimeZone(secondsFromGMT: 0)! }
}
