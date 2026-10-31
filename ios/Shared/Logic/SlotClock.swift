import Foundation

enum SlotClock {
    static let minutesPerDay = 1440

    static func step(minutes: Int) -> TimeInterval {
        Double(max(minutes, 1)) * 60
    }

    static func slotsPerDay(minutes: Int) -> Int {
        Int((Double(minutesPerDay) / Double(max(minutes, 1))).rounded(.up))
    }

    static func slot(at date: Date, minutes: Int, calendar: Calendar = Persian.calendar) -> Int {
        dayOrdinal(of: date, calendar: calendar) * slotsPerDay(minutes: minutes) + slotInDay(of: date, minutes: minutes, calendar: calendar)
    }

    static func start(of date: Date, minutes: Int, calendar: Calendar = Persian.calendar) -> Date {
        let dayStart = calendar.startOfDay(for: date)
        return dayStart.addingTimeInterval(Double(slotInDay(of: date, minutes: minutes, calendar: calendar)) * step(minutes: minutes))
    }

    static func next(after date: Date, minutes: Int, calendar: Calendar = Persian.calendar) -> Date {
        let candidate = start(of: date, minutes: minutes, calendar: calendar).addingTimeInterval(step(minutes: minutes))
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) else { return candidate }
        return min(candidate, calendar.startOfDay(for: tomorrow))
    }

    static func boundaries(after date: Date, minutes: Int, count: Int, calendar: Calendar = Persian.calendar) -> [Date] {
        var result: [Date] = []
        var cursor = date
        for _ in 0..<max(count, 0) {
            cursor = next(after: cursor, minutes: minutes, calendar: calendar)
            result.append(cursor)
        }
        return result
    }

    private static func slotInDay(of date: Date, minutes: Int, calendar: Calendar) -> Int {
        let elapsed = date.timeIntervalSince(calendar.startOfDay(for: date))
        return min(Int(elapsed / step(minutes: minutes)), slotsPerDay(minutes: minutes) - 1)
    }

    private static func dayOrdinal(of date: Date, calendar: Calendar) -> Int {
        let epoch = Date(timeIntervalSince1970: 0)
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: epoch), to: calendar.startOfDay(for: date)).day ?? 0
    }
}
