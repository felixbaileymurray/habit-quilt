import Foundation
import SQLite3

protocol HabitRepositoryProtocol: AnyObject {
    func fetchActiveHabit() throws -> HabitRecord?
    func upsertHabit(_ habit: HabitRecord) throws
    func renameHabit(id: String, name: String) throws

    func fetchDay(date: String) throws -> DayRecord?
    func upsertDay(_ day: DayRecord) throws
    func fetchDays(from start: String, to end: String) throws -> [DayRecord]
    func markPreserved(date: String, at preservedAt: Date) throws

    func getSetting(_ key: SettingsKey) throws -> String?
    func setSetting(_ key: SettingsKey, value: String) throws
}

final class HabitRepository: HabitRepositoryProtocol {
    private let store: SQLiteStore

    init(store: SQLiteStore) {
        self.store = store
    }

    // MARK: - Habit

    func fetchActiveHabit() throws -> HabitRecord? {
        let stmt = try store.prepare(
            "SELECT id, name, created_at, archived_at FROM habit WHERE archived_at IS NULL LIMIT 1;"
        )
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return HabitRecord(
            id: columnText(stmt, 0),
            name: columnText(stmt, 1),
            createdAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 2)),
            archivedAt: sqlite3_column_type(stmt, 3) == SQLITE_NULL
                ? nil
                : Date(timeIntervalSince1970: sqlite3_column_double(stmt, 3))
        )
    }

    func upsertHabit(_ habit: HabitRecord) throws {
        let stmt = try store.prepare(
            """
            INSERT INTO habit(id, name, created_at, archived_at)
            VALUES (?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                name = excluded.name,
                archived_at = excluded.archived_at;
            """
        )
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, habit.id)
        try bindText(stmt, 2, habit.name)
        try bindDouble(stmt, 3, habit.createdAt.timeIntervalSince1970)
        if let archived = habit.archivedAt {
            try bindDouble(stmt, 4, archived.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(stmt, 4)
        }
        try stepDone(stmt)
    }

    func renameHabit(id: String, name: String) throws {
        let stmt = try store.prepare("UPDATE habit SET name = ? WHERE id = ?;")
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, name)
        try bindText(stmt, 2, id)
        try stepDone(stmt)
    }

    // MARK: - Day

    func fetchDay(date: String) throws -> DayRecord? {
        let stmt = try store.prepare(
            """
            SELECT date, habit_id, doodle_json, thumb_path, created_at, updated_at, preserved_at, is_example
            FROM day WHERE date = ?;
            """
        )
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, date)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return dayFromRow(stmt)
    }

    func upsertDay(_ day: DayRecord) throws {
        let stmt = try store.prepare(
            """
            INSERT INTO day(date, habit_id, doodle_json, thumb_path, created_at, updated_at, preserved_at, is_example)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(date) DO UPDATE SET
                habit_id = excluded.habit_id,
                doodle_json = excluded.doodle_json,
                thumb_path = excluded.thumb_path,
                updated_at = excluded.updated_at,
                preserved_at = excluded.preserved_at,
                is_example = excluded.is_example;
            """
        )
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, day.date)
        try bindText(stmt, 2, day.habitId)
        try bindOptionalText(stmt, 3, day.doodleJSON)
        try bindOptionalText(stmt, 4, day.thumbPath)
        try bindDouble(stmt, 5, day.createdAt.timeIntervalSince1970)
        try bindDouble(stmt, 6, day.updatedAt.timeIntervalSince1970)
        if let preserved = day.preservedAt {
            try bindDouble(stmt, 7, preserved.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(stmt, 7)
        }
        sqlite3_bind_int(stmt, 8, day.isExample ? 1 : 0)
        try stepDone(stmt)
    }

    func fetchDays(from start: String, to end: String) throws -> [DayRecord] {
        let stmt = try store.prepare(
            """
            SELECT date, habit_id, doodle_json, thumb_path, created_at, updated_at, preserved_at, is_example
            FROM day WHERE date >= ? AND date <= ? ORDER BY date ASC;
            """
        )
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, start)
        try bindText(stmt, 2, end)
        var rows: [DayRecord] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            rows.append(dayFromRow(stmt))
        }
        return rows
    }

    func markPreserved(date: String, at preservedAt: Date) throws {
        let stmt = try store.prepare(
            """
            UPDATE day SET preserved_at = ?, updated_at = ?
            WHERE date = ? AND preserved_at IS NULL;
            """
        )
        defer { sqlite3_finalize(stmt) }
        let ts = preservedAt.timeIntervalSince1970
        try bindDouble(stmt, 1, ts)
        try bindDouble(stmt, 2, ts)
        try bindText(stmt, 3, date)
        try stepDone(stmt)
    }

    // MARK: - Settings

    func getSetting(_ key: SettingsKey) throws -> String? {
        let stmt = try store.prepare("SELECT value FROM settings WHERE key = ?;")
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, key.rawValue)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return columnText(stmt, 0)
    }

    func setSetting(_ key: SettingsKey, value: String) throws {
        let stmt = try store.prepare(
            """
            INSERT INTO settings(key, value) VALUES (?, ?)
            ON CONFLICT(key) DO UPDATE SET value = excluded.value;
            """
        )
        defer { sqlite3_finalize(stmt) }
        try bindText(stmt, 1, key.rawValue)
        try bindText(stmt, 2, value)
        try stepDone(stmt)
    }

    // MARK: - Helpers

    private func dayFromRow(_ stmt: OpaquePointer) -> DayRecord {
        DayRecord(
            date: columnText(stmt, 0),
            habitId: columnText(stmt, 1),
            doodleJSON: sqlite3_column_type(stmt, 2) == SQLITE_NULL ? nil : columnText(stmt, 2),
            thumbPath: sqlite3_column_type(stmt, 3) == SQLITE_NULL ? nil : columnText(stmt, 3),
            createdAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4)),
            updatedAt: Date(timeIntervalSince1970: sqlite3_column_double(stmt, 5)),
            preservedAt: sqlite3_column_type(stmt, 6) == SQLITE_NULL
                ? nil
                : Date(timeIntervalSince1970: sqlite3_column_double(stmt, 6)),
            isExample: sqlite3_column_int(stmt, 7) != 0
        )
    }

    private func columnText(_ stmt: OpaquePointer, _ index: Int32) -> String {
        guard let c = sqlite3_column_text(stmt, index) else { return "" }
        return String(cString: c)
    }

    private func bindText(_ stmt: OpaquePointer, _ index: Int32, _ value: String) throws {
        let status = value.withCString { cString in
            // SQLITE_TRANSIENT: SQLite copies the bytes before returning.
            sqlite3_bind_text(stmt, index, cString, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        }
        if status != SQLITE_OK {
            throw SQLiteError.bindFailed(store.lastErrorMessage())
        }
    }

    private func bindOptionalText(_ stmt: OpaquePointer, _ index: Int32, _ value: String?) throws {
        if let value {
            try bindText(stmt, index, value)
        } else {
            sqlite3_bind_null(stmt, index)
        }
    }

    private func bindDouble(_ stmt: OpaquePointer, _ index: Int32, _ value: Double) throws {
        if sqlite3_bind_double(stmt, index, value) != SQLITE_OK {
            throw SQLiteError.bindFailed(store.lastErrorMessage())
        }
    }

    private func stepDone(_ stmt: OpaquePointer) throws {
        if sqlite3_step(stmt) != SQLITE_DONE {
            throw SQLiteError.stepFailed(store.lastErrorMessage())
        }
    }
}
