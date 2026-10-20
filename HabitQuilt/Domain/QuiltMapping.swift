import Foundation
import HabitQuiltDomain

/// Maps persistence rows into HabitQuiltDomain types for quilt layout.
enum QuiltMapping {
    /// Builds a domain day record used only for layout (`hasDoodle` / blanks).
    /// Doodle JSON stays canvas-owned; we only need a non-nil doodle marker here.
    static func domainDayRecord(
        from row: HabitQuilt.DayRecord,
        utcOffsetSeconds: Int
    ) -> HabitQuiltDomain.DayRecord? {
        guard let day = DayKey.parse(row.date, utcOffsetSeconds: utcOffsetSeconds) else {
            return nil
        }
        guard let habitID = UUID(uuidString: row.habitId) else {
            return nil
        }
        let doodle: HabitQuiltDomain.DoodleDocument? = row.doodleJSON == nil
            ? nil
            : HabitQuiltDomain.DoodleDocument()
        return HabitQuiltDomain.DayRecord(
            day: day,
            habitID: habitID,
            doodle: doodle,
            thumbPath: row.thumbPath,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            preservedAt: row.preservedAt,
            isExample: row.isExample
        )
    }

    static func recordsByDay(
        from rows: [HabitQuilt.DayRecord],
        utcOffsetSeconds: Int
    ) -> [String: HabitQuiltDomain.DayRecord] {
        var map: [String: HabitQuiltDomain.DayRecord] = [:]
        for row in rows {
            if let domain = domainDayRecord(from: row, utcOffsetSeconds: utcOffsetSeconds) {
                map[domain.day.rawValue] = domain
            }
        }
        return map
    }
}
