import Foundation
import SQLite3

enum SQLiteError: Error, LocalizedError {
    case openFailed(String)
    case prepareFailed(String)
    case stepFailed(String)
    case bindFailed(String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let m), .prepareFailed(let m), .stepFailed(let m), .bindFailed(let m):
            return m
        }
    }
}

/// Thin SQLite3 wrapper for Habit Quilt. No GRDB dependency in M1 scaffold.
final class SQLiteStore: @unchecked Sendable {
    private var db: OpaquePointer?
    private let path: String

    init(path: String) throws {
        self.path = path
        if sqlite3_open(path, &db) != SQLITE_OK {
            throw SQLiteError.openFailed(lastErrorMessage())
        }
        try execute("PRAGMA foreign_keys = ON;")
    }

    deinit {
        sqlite3_close(db)
    }

    static func applicationSupportPath(fileName: String = "habitquilt.sqlite") throws -> String {
        let fm = FileManager.default
        let root = try fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = root.appendingPathComponent("HabitQuilt", isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName).path
    }

    func migrate() throws {
        try execute("""
            CREATE TABLE IF NOT EXISTS schema_migrations (
                version INTEGER PRIMARY KEY NOT NULL
            );
            """)

        let applied = try appliedVersions()
        for migration in SchemaMigration.allCases where !applied.contains(migration.rawValue) {
            try execute("BEGIN;")
            do {
                for sql in migration.sqlStatements {
                    try execute(sql)
                }
                try execute("INSERT INTO schema_migrations(version) VALUES (\(migration.rawValue));")
                try execute("COMMIT;")
            } catch {
                try? execute("ROLLBACK;")
                throw error
            }
        }
    }

    func execute(_ sql: String) throws {
        var err: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            let message = err.map { String(cString: $0) } ?? lastErrorMessage()
            sqlite3_free(err)
            throw SQLiteError.stepFailed(message)
        }
    }

    func prepare(_ sql: String) throws -> OpaquePointer {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK {
            throw SQLiteError.prepareFailed(lastErrorMessage())
        }
        guard let stmt else {
            throw SQLiteError.prepareFailed("nil statement")
        }
        return stmt
    }

    func lastErrorMessage() -> String {
        String(cString: sqlite3_errmsg(db))
    }

    private func appliedVersions() throws -> Set<Int> {
        let stmt = try prepare("SELECT version FROM schema_migrations;")
        defer { sqlite3_finalize(stmt) }
        var versions = Set<Int>()
        while sqlite3_step(stmt) == SQLITE_ROW {
            versions.insert(Int(sqlite3_column_int(stmt, 0)))
        }
        return versions
    }
}
