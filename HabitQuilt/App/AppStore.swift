import Foundation
import Observation

/// App-level state over the repository. Keeps views free of SQL.
/// Persistence models stay app-local; HabitQuiltDomain is used via `DayClock`.
@Observable
@MainActor
final class AppStore {
    private(set) var habit: HabitRecord?
    private(set) var todayDay: DayRecord?
    var hideBlankDays: Bool = false
    /// Session-only doodle aid; not written into doodle JSON.
    var doodleDotGridVisible: Bool = false
    /// Day date string for an open doodle editor session (midnight auto-preserve).
    var openDoodleSessionDay: String?

    private let repository: HabitRepositoryProtocol
    private let clock: DayClock
    private let preservation: DayPreservationCoordinator
    private var lastTick: Date

    init(repository: HabitRepositoryProtocol, clock: DayClock = DayClock()) {
        self.repository = repository
        self.clock = clock
        self.preservation = DayPreservationCoordinator(repository: repository, clock: clock)
        self.lastTick = Date()
        refresh()
    }

    var needsHabitSetup: Bool { habit == nil }

    var todayDateString: String { clock.localDateString() }

    func refresh() {
        do {
            habit = try repository.fetchActiveHabit()
            todayDay = try repository.fetchDay(date: todayDateString)
            if let raw = try repository.getSetting(.hideBlankDays) {
                hideBlankDays = (raw == "1")
            }
            if let raw = try repository.getSetting(.dotGridDefault) {
                doodleDotGridVisible = (raw == "1")
            }
        } catch {
            // Scaffold: surface via future error UI.
            assertionFailure("refresh failed: \(error)")
        }
    }

    func createHabit(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let record = HabitRecord(
            id: UUID().uuidString,
            name: trimmed,
            createdAt: Date(),
            archivedAt: nil
        )
        do {
            try repository.upsertHabit(record)
            habit = record
        } catch {
            assertionFailure("createHabit failed: \(error)")
        }
    }

    func renameHabit(name: String) {
        guard let habit else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try repository.renameHabit(id: habit.id, name: trimmed)
            self.habit = HabitRecord(
                id: habit.id,
                name: trimmed,
                createdAt: habit.createdAt,
                archivedAt: habit.archivedAt
            )
        } catch {
            assertionFailure("renameHabit failed: \(error)")
        }
    }

    /// Start or open today's doodle. Creates a day row if needed.
    func beginTodayDoodle() {
        guard let habit else { return }
        let today = todayDateString
        do {
            if try repository.fetchDay(date: today) == nil {
                let now = Date()
                let day = DayRecord(
                    date: today,
                    habitId: habit.id,
                    doodleJSON: nil,
                    thumbPath: nil,
                    createdAt: now,
                    updatedAt: now,
                    preservedAt: nil,
                    isExample: false
                )
                try repository.upsertDay(day)
            }
            todayDay = try repository.fetchDay(date: today)
            openDoodleSessionDay = today
        } catch {
            assertionFailure("beginTodayDoodle failed: \(error)")
        }
    }

    func saveDoodleJSON(_ json: String) {
        guard var day = todayDay else { return }
        guard clock.editability(of: day.date) == .editable else { return }
        day.doodleJSON = json
        day.updatedAt = Date()
        do {
            try repository.upsertDay(day)
            todayDay = day
        } catch {
            assertionFailure("saveDoodleJSON failed: \(error)")
        }
    }

    func setHideBlankDays(_ value: Bool) {
        hideBlankDays = value
        try? repository.setSetting(.hideBlankDays, value: value ? "1" : "0")
    }

    /// Dot-grid default preference (UI only). Session visibility is separate and not in doodle docs.
    func setDotGridDefault(_ value: Bool) {
        doodleDotGridVisible = value
        try? repository.setSetting(.dotGridDefault, value: value ? "1" : "0")
    }

    /// Call on scene phase / timer ticks to enforce midnight auto-preserve.
    func tickCalendarBoundary(now: Date = Date()) {
        do {
            _ = try preservation.autoPreserveOpenSessionIfMidnightPassed(
                openSessionDay: openDoodleSessionDay,
                from: lastTick,
                to: now
            )
            if let open = openDoodleSessionDay,
               clock.editability(of: open, relativeTo: now) == .preserved {
                openDoodleSessionDay = nil
            }
            // Also preserve yesterday if still unmarked.
            let yesterday = clock.calendar.date(byAdding: .day, value: -1, to: now).map {
                clock.localDateString(for: $0)
            }
            if let yesterday {
                _ = try preservation.preserveIfNeeded(dayDate: yesterday, now: now)
            }
            refresh()
        } catch {
            assertionFailure("tickCalendarBoundary failed: \(error)")
        }
        lastTick = now
    }

    func endDoodleSession() {
        openDoodleSessionDay = nil
    }
}
