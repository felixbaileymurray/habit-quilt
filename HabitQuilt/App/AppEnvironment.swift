import Foundation

@MainActor
enum AppEnvironment {
    static func makeStore() -> AppStore {
        do {
            #if DEBUG
            // Prefer a writable path; unit tests inject their own repository.
            let path = try SQLiteStore.applicationSupportPath()
            #else
            let path = try SQLiteStore.applicationSupportPath()
            #endif
            let store = try SQLiteStore(path: path)
            try store.migrate()
            let repo = HabitRepository(store: store)
            return AppStore(repository: repo)
        } catch {
            fatalError("Failed to open Habit Quilt database: \(error)")
        }
    }
}
