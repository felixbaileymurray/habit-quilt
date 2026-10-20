import Foundation

enum SchemaMigration: Int, CaseIterable, Comparable {
    case v1 = 1

    static func < (lhs: SchemaMigration, rhs: SchemaMigration) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var sqlStatements: [String] {
        switch self {
        case .v1:
            return [
                """
                CREATE TABLE IF NOT EXISTS habit (
                    id TEXT PRIMARY KEY NOT NULL,
                    name TEXT NOT NULL,
                    created_at REAL NOT NULL,
                    archived_at REAL
                );
                """,
                """
                CREATE TABLE IF NOT EXISTS day (
                    date TEXT PRIMARY KEY NOT NULL,
                    habit_id TEXT NOT NULL,
                    doodle_json TEXT,
                    thumb_path TEXT,
                    created_at REAL NOT NULL,
                    updated_at REAL NOT NULL,
                    preserved_at REAL,
                    is_example INTEGER NOT NULL DEFAULT 0,
                    FOREIGN KEY (habit_id) REFERENCES habit(id)
                );
                """,
                """
                CREATE TABLE IF NOT EXISTS settings (
                    key TEXT PRIMARY KEY NOT NULL,
                    value TEXT NOT NULL
                );
                """,
                """
                CREATE TABLE IF NOT EXISTS schema_migrations (
                    version INTEGER PRIMARY KEY NOT NULL
                );
                """,
            ]
        }
    }
}
