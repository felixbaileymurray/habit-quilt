import Foundation

/// A local calendar day key in `YYYY-MM-DD` form, plus the UTC offset (seconds)
/// that was in effect when the day was first recorded.
///
/// Day identity is always local-calendar based — never a UTC date string alone.
/// Equality and hashing use `rawValue` only; `utcOffsetSeconds` is entry metadata.
public struct DayKey: Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    public let rawValue: String
    /// Seconds east of UTC at entry time (e.g. `-18000` for America/New_York in winter).
    public let utcOffsetSeconds: Int

    public var description: String { rawValue }

    public init(rawValue: String, utcOffsetSeconds: Int) {
        self.rawValue = rawValue
        self.utcOffsetSeconds = utcOffsetSeconds
    }

    public static func == (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    /// Builds a day key from an absolute instant in a given time zone.
    public init(date: Date, timeZone: TimeZone) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else {
            preconditionFailure("Calendar failed to decompose date \(date)")
        }
        self.rawValue = String(format: "%04d-%02d-%02d", year, month, day)
        self.utcOffsetSeconds = timeZone.secondsFromGMT(for: date)
    }

    /// Parses a `YYYY-MM-DD` string. Returns `nil` if the format or calendar date is invalid.
    public static func parse(_ rawValue: String, utcOffsetSeconds: Int = 0) -> DayKey? {
        let parts = rawValue.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]), parts[0].count == 4,
              let month = Int(parts[1]), parts[1].count == 2,
              let day = Int(parts[2]), parts[2].count == 2,
              (1...12).contains(month),
              (1...31).contains(day)
        else {
            return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        guard calendar.date(from: comps) != nil else { return nil }
        return DayKey(rawValue: rawValue, utcOffsetSeconds: utcOffsetSeconds)
    }

    /// Local calendar "today" in `timeZone` at `now`.
    public static func today(now: Date = Date(), timeZone: TimeZone = .current) -> DayKey {
        DayKey(date: now, timeZone: timeZone)
    }

    /// Inclusive sequence of day keys from `start` through `end` (local calendar days).
    /// Uses a fixed GMT calendar so the string keys advance by civil day, independent of DST.
    public static func days(
        from start: DayKey,
        through end: DayKey
    ) -> [DayKey] {
        guard start <= end else { return [] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

        guard let startDate = Self.noonUTC(for: start.rawValue, calendar: calendar),
              let endDate = Self.noonUTC(for: end.rawValue, calendar: calendar)
        else {
            return []
        }

        var result: [DayKey] = []
        var cursor = startDate
        while cursor <= endDate {
            let comps = calendar.dateComponents([.year, .month, .day], from: cursor)
            let raw = String(format: "%04d-%02d-%02d", comps.year!, comps.month!, comps.day!)
            result.append(DayKey(rawValue: raw, utcOffsetSeconds: start.utcOffsetSeconds))
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    public static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Instant of local midnight that *starts* this day in `timeZone`.
    public func startOfDay(in timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = rawValue.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var comps = DateComponents()
        comps.year = parts[0]
        comps.month = parts[1]
        comps.day = parts[2]
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return calendar.date(from: comps)
    }

    /// Instant of local midnight that *ends* this day (start of the next local day).
    public func endOfDay(in timeZone: TimeZone) -> Date? {
        guard let start = startOfDay(in: timeZone) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(byAdding: .day, value: 1, to: start)
    }

    private static func noonUTC(for raw: String, calendar: Calendar) -> Date? {
        let parts = raw.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var comps = DateComponents()
        comps.year = parts[0]
        comps.month = parts[1]
        comps.day = parts[2]
        comps.hour = 12
        return calendar.date(from: comps)
    }
}
