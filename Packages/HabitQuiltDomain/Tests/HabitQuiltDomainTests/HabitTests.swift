import Foundation
import Testing
@testable import HabitQuiltDomain

@Suite("Habit")
struct HabitTests {
    @Test("rename keeps the same id so quilt history continues")
    func renameKeepsIdentity() {
        let id = UUID()
        var habit = Habit(id: id, name: "Morning stretch")
        habit.rename(to: "Evening stretch")
        #expect(habit.id == id)
        #expect(habit.name == "Evening stretch")

        let renamed = Habit(id: id, name: "A").renamed(to: "B")
        #expect(renamed.id == id)
        #expect(renamed.name == "B")
    }

    @Test("day records stay keyed by day under the same habit id after rename")
    func quiltHistoryUnaffectedByRename() throws {
        let habitID = UUID()
        var habit = Habit(id: habitID, name: "Draw")
        let day = try #require(DayKey.parse("2026-01-15"))
        let record = DayRecord(
            day: day,
            habitID: habitID,
            doodle: DoodleDocument(ops: [
                .stroke(tool: .pen, ink: .blue, points: [
                    StrokePoint(x: 10, y: 20, pressure: 0.5, ms: 0),
                ]),
            ])
        )
        habit.rename(to: "Sketch daily")
        #expect(record.habitID == habit.id)
        #expect(record.hasDoodle)
    }
}
