import Foundation
import Testing
@testable import HabitQuiltDomain

@Suite("QuiltLayout")
struct QuiltLayoutTests {
    @Test("oldest top / newest bottom; fill top-left row by row")
    func photosStyleFill() throws {
        let start = try #require(DayKey.parse("2026-01-01"))
        let end = try #require(DayKey.parse("2026-01-07"))
        let habitID = UUID()
        var records: [String: DayRecord] = [:]
        for day in DayKey.days(from: start, through: end) {
            // Put doodles on odd calendar days only
            let dayNum = Int(day.rawValue.split(separator: "-").last!)!
            if dayNum % 2 == 1 {
                records[day.rawValue] = DayRecord(
                    day: day,
                    habitID: habitID,
                    doodle: DoodleDocument()
                )
            }
        }

        let tiles = QuiltLayout.tiles(
            from: start,
            through: end,
            recordsByDay: records,
            columns: .three,
            hideBlanks: false
        )

        #expect(tiles.count == 7)
        #expect(tiles.map(\.day.rawValue) == [
            "2026-01-01", "2026-01-02", "2026-01-03",
            "2026-01-04", "2026-01-05", "2026-01-06",
            "2026-01-07",
        ])
        // Row 0: indices 0,1,2 → cols 0,1,2
        #expect(tiles[0].row == 0 && tiles[0].column == 0)
        #expect(tiles[1].row == 0 && tiles[1].column == 1)
        #expect(tiles[2].row == 0 && tiles[2].column == 2)
        // Row 1
        #expect(tiles[3].row == 1 && tiles[3].column == 0)
        #expect(tiles[6].row == 2 && tiles[6].column == 0)
        #expect(QuiltLayout.rowCount(tileCount: 7, columns: .three) == 3)
    }

    @Test("hide-blanks filter keeps completed days only and reflows")
    func hideBlanks() throws {
        let start = try #require(DayKey.parse("2026-02-01"))
        let end = try #require(DayKey.parse("2026-02-05"))
        let habitID = UUID()
        let completed = ["2026-02-01", "2026-02-03", "2026-02-05"]
        var records: [String: DayRecord] = [:]
        for raw in completed {
            let day = try #require(DayKey.parse(raw))
            records[raw] = DayRecord(day: day, habitID: habitID, doodle: DoodleDocument())
        }

        let filtered = QuiltLayout.tiles(
            from: start,
            through: end,
            recordsByDay: records,
            columns: .two,
            hideBlanks: true
        )
        #expect(filtered.map(\.day.rawValue) == completed)
        #expect(filtered.allSatisfy { !$0.isBlank })
        #expect(filtered[0].row == 0 && filtered[0].column == 0)
        #expect(filtered[1].row == 0 && filtered[1].column == 1)
        #expect(filtered[2].row == 1 && filtered[2].column == 0)

        let all = QuiltLayout.tiles(
            from: start,
            through: end,
            recordsByDay: records,
            columns: .two,
            hideBlanks: false
        )
        let viaHelper = QuiltLayout.hideBlanks(
            days: all.map(\.day),
            recordsByDay: records
        )
        #expect(viaHelper.map(\.rawValue) == completed)

        let reflowed = QuiltLayout.applyingHideBlanks(to: all, columns: .two)
        #expect(reflowed.map(\.day.rawValue) == completed)
    }

    @Test("position helper matches row-major top-left fill")
    func positionHelper() {
        #expect(QuiltLayout.position(index: 0, columns: .five) == (0, 0))
        #expect(QuiltLayout.position(index: 4, columns: .five) == (0, 4))
        #expect(QuiltLayout.position(index: 5, columns: .five) == (1, 0))
        #expect(QuiltLayout.position(index: 11, columns: .five) == (2, 1))
    }

    @Test("column snap set matches Photos-style discrete counts")
    func columnSnaps() {
        #expect(QuiltColumnCount.snaps.map(\.rawValue) == [1, 2, 3, 5, 7, 10, 15, 20])
    }

    @Test("blank tiles when no record or empty doodle")
    func blankDetection() throws {
        let day = try #require(DayKey.parse("2026-03-01"))
        let habitID = UUID()
        let withDoodle = DayRecord(day: day, habitID: habitID, doodle: DoodleDocument())
        let without = DayRecord(day: day, habitID: habitID, doodle: nil)

        let tiles = QuiltLayout.tiles(
            from: day,
            through: day,
            recordsByDay: [day.rawValue: without],
            columns: .one
        )
        #expect(tiles[0].isBlank)

        let filled = QuiltLayout.tiles(
            from: day,
            through: day,
            recordsByDay: [day.rawValue: withDoodle],
            columns: .one
        )
        #expect(!filled[0].isBlank)
    }
}
