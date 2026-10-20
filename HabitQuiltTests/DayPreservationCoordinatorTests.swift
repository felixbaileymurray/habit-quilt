import XCTest
@testable import HabitQuilt

@MainActor
final class DayPreservationCoordinatorTests: XCTestCase {
    private var store: SQLiteStore!
    private var repo: HabitRepository!
    private var dbPath: String!
    private var clock: DayClock!
    private var coordinator: DayPreservationCoordinator!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dbPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("habitquilt-coord-\(UUID().uuidString).sqlite")
            .path
        store = try SQLiteStore(path: dbPath)
        try store.migrate()
        repo = HabitRepository(store: store)

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        clock = DayClock(calendar: cal, timeZone: cal.timeZone)
        coordinator = DayPreservationCoordinator(repository: repo, clock: clock)

        try repo.upsertHabit(
            HabitRecord(id: "h1", name: "Walk", createdAt: Date(), archivedAt: nil)
        )
        let created = Date(timeIntervalSince1970: 1_000)
        try repo.upsertDay(
            DayRecord(
                date: "2026-10-19",
                habitId: "h1",
                doodleJSON: #"{"v":1,"ops":[]}"#,
                thumbPath: nil,
                createdAt: created,
                updatedAt: created,
                preservedAt: nil,
                isExample: false
            )
        )
    }

    override func tearDown() {
        coordinator = nil
        repo = nil
        store = nil
        if let dbPath {
            try? FileManager.default.removeItem(atPath: dbPath)
        }
        super.tearDown()
    }

    func testPreserveIfNeededAfterDayEnds() throws {
        let nextMorning = makeDate(2026, 10, 20, 8, 0)
        let did = try coordinator.preserveIfNeeded(dayDate: "2026-10-19", now: nextMorning)
        XCTAssertTrue(did)
        XCTAssertNotNil(try repo.fetchDay(date: "2026-10-19")?.preservedAt)
    }

    func testPreserveIfNeededSkippedWhileStillToday() throws {
        let sameDay = makeDate(2026, 10, 19, 18, 0)
        let did = try coordinator.preserveIfNeeded(dayDate: "2026-10-19", now: sameDay)
        XCTAssertFalse(did)
        XCTAssertNil(try repo.fetchDay(date: "2026-10-19")?.preservedAt)
    }

    func testMidnightAutoPreserveOpenSession() throws {
        let previous = makeDate(2026, 10, 19, 23, 59)
        let next = makeDate(2026, 10, 20, 0, 0, 5)
        let did = try coordinator.autoPreserveOpenSessionIfMidnightPassed(
            openSessionDay: "2026-10-19",
            from: previous,
            to: next
        )
        XCTAssertTrue(did)
        XCTAssertNotNil(try repo.fetchDay(date: "2026-10-19")?.preservedAt)
    }

    private func makeDate(
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
        return clock.calendar.date(from: comps)!
    }
}
