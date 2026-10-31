import Foundation

extension HabitItem {
    func isDone(_ date: Date) -> Bool {
        days.contains(DayKey.string(date))
    }

    mutating func toggle(_ date: Date) {
        let key = DayKey.string(date)
        if days.contains(key) {
            days.remove(key)
        } else {
            days.insert(key)
        }
    }

    func streak(asOf date: Date) -> Int {
        var cursor = isDone(date) ? date : Persian.shift(date, days: -1)
        var length = 0
        while length < days.count && isDone(cursor) {
            length += 1
            cursor = Persian.shift(cursor, days: -1)
        }
        return length
    }

    func bestStreak() -> Int {
        let dates = days.sorted().compactMap { DayKey.date($0) }
        var best = 0
        var run = 0
        var previous: Date?
        for date in dates {
            let continues = previous.map { DayKey.string(Persian.shift($0, days: 1)) == DayKey.string(date) } ?? false
            run = continues ? run + 1 : 1
            best = max(best, run)
            previous = date
        }
        return best
    }

    func rate(lastDays count: Int, asOf date: Date) -> Double {
        guard count > 0 else { return 0 }
        let done = lastDays(count, asOf: date).filter { isDone($0) }.count
        return Double(done) / Double(count)
    }

    func lastDays(_ count: Int, asOf date: Date) -> [Date] {
        guard count > 0 else { return [] }
        let today = Persian.calendar.startOfDay(for: date)
        return (0..<count).map { Persian.shift(today, days: $0 - count + 1) }
    }
}
