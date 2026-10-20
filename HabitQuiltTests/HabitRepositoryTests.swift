import XCTest
@testable import HabitQuilt

final class HabitRepositoryTests: XCTestCase {
    private var store: SQLiteStore!
    private var repo: HabitRepository!
    private var dbPath: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        dbPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("habitquilt-test-\(UUID().uuidString).sqlite")
            .path
        store = try SQLiteStore(path: dbPath)
        try store.migrate()
        repo = HabitRepository(store: store)
    }

    override func tearDown() {
        store = nil
        repo = nil
        if let dbPath {
            try? FileManager.default.removeItem(atPath: dbPath)
        }
        super.tearDown()
    }

    func testUpsertAndFetchHabit() throws {
        let habit = HabitRecord(
            id: "h1",
            name: "Stretch",
            createdAt: Date(timeIntervalSince1970: 1_000),
            archivedAt: nil
        )
        try repo.upsertHabit(habit)
        let fetched = try repo.fetchActiveHabit()
        XCTAssertEqual(fetched?.id, "h1")
        XCTAssertEqual(fetched?.name, "Stretch")
    }

    func testRenameHabitKeepsId() throws {
        try repo.upsertHabit(
            HabitRecord(id: "h1", name: "A", createdAt: Date(), archivedAt: nil)
        )
        try repo.renameHabit(id: "h1", name: "B")
        XCTAssertEqual(try repo.fetchActiveHabit()?.name, "B")
        XCTAssertEqual(try repo.fetchActiveHabit()?.id, "h1")
    }

    func testDayUpsertAndPreserve() throws {
        try repo.upsertHabit(
            HabitRecord(id: "h1", name: "A", createdAt: Date(), archivedAt: nil)
        )
        let now = Date(timeIntervalSince1970: 2_000)
        var day = DayRecord(
            date: "2026-10-19",
            habitId: "h1",
            doodleJSON: #"{"v":1,"paletteId":"riso-2026a","paper":"light","ops":[]}"#,
            thumbPath: nil,
            createdAt: now,
            updatedAt: now,
            preservedAt: nil,
            isExample: false
        )
        try repo.upsertDay(day)
        XCTAssertFalse(try repo.fetchDay(date: "2026-10-19")!.isPreserved)

        let preservedAt = Date(timeIntervalSince1970: 3_000)
        try repo.markPreserved(date: "2026-10-19", at: preservedAt)
        let fetched = try repo.fetchDay(date: "2026-10-19")
        XCTAssertEqual(fetched?.preservedAt?.timeIntervalSince1970, 3_000)
    }

    func testSettingsRoundTrip() throws {
        try repo.setSetting(.hideBlankDays, value: "1")
        XCTAssertEqual(try repo.getSetting(.hideBlankDays), "1")
        try repo.setSetting(.dotGridDefault, value: "0")
        XCTAssertEqual(try repo.getSetting(.dotGridDefault), "0")
    }
}
