import XCTest
@testable import HabitQuilt
import HabitQuiltDomain

final class DayPreservationTests: XCTestCase {
    private var clock: DayClock!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = cal
        clock = DayClock(calendar: cal, timeZone: cal.timeZone)
    }

    func testEditableWhileSameLocalDay() {
        XCTAssertEqual(
            clock.editability(of: "2026-10-20", relativeTo: date(2026, 10, 20, 15, 0)),
            .editable
        )
    }

    func testPreservedAfterLocalDayEnds() {
        XCTAssertEqual(
            clock.editability(of: "2026-10-19", relativeTo: date(2026, 10, 20, 0, 1)),
            .preserved
        )
    }

    func testMidnightAutoPreserveWhenSessionOpenForEndingDay() {
        let previous = date(2026, 10, 19, 23, 59)
        let next = date(2026, 10, 20, 0, 0, 1)
        let day = clock.dayToAutoPreserveIfCrossingMidnight(
            openSessionDay: "2026-10-19",
            from: previous,
            to: next
        )
        XCTAssertEqual(day, "2026-10-19")
    }

    func testNoAutoPreserveWhenSessionIsAlreadyNewDay() {
        let previous = date(2026, 10, 19, 23, 59)
        let next = date(2026, 10, 20, 0, 0, 1)
        let day = clock.dayToAutoPreserveIfCrossingMidnight(
            openSessionDay: "2026-10-20",
            from: previous,
            to: next
        )
        XCTAssertNil(day)
    }

    func testNoAutoPreserveWithoutDayBoundary() {
        let previous = date(2026, 10, 19, 10, 0)
        let next = date(2026, 10, 19, 11, 0)
        let day = clock.dayToAutoPreserveIfCrossingMidnight(
            openSessionDay: "2026-10-19",
            from: previous,
            to: next
        )
        XCTAssertNil(day)
    }

    func testLocalDateStringFormat() {
        XCTAssertEqual(clock.localDateString(for: date(2026, 3, 5, 8, 0)), "2026-03-05")
    }

    func testNextLocalMidnight() {
        let noon = date(2026, 10, 19, 12, 0)
        let midnight = clock.nextLocalMidnight(after: noon)
        XCTAssertEqual(clock.localDateString(for: midnight), "2026-10-20")
        let comps = calendar.dateComponents([.hour, .minute, .second], from: midnight)
        XCTAssertEqual(comps.hour, 0)
        XCTAssertEqual(comps.minute, 0)
        XCTAssertEqual(comps.second, 0)
    }

    func testDomainPreservationRulesMatchClock() {
        let now = date(2026, 10, 20, 9, 0)
        let day = DayKey.parse("2026-10-20", utcOffsetSeconds: 0)!
        XCTAssertEqual(
            PreservationRules.editability(of: day, now: now, timeZone: calendar.timeZone),
            clock.editability(of: "2026-10-20", relativeTo: now)
        )
    }

    private func date(
        _ y: Int, _ m: Int, _ d: Int,
        _ h: Int, _ min: Int, _ s: Int = 0
    ) -> Date {
        var comps = DateComponents()
        comps.year = y
        comps.month = m
        comps.day = d
        comps.hour = h
        comps.minute = min
        comps.second = s
        return calendar.date(from: comps)!
    }
}
