import Foundation

extension CounterItem {
    func count(on date: Date) -> Int {
        counts[DayKey.string(date)] ?? 0
    }

    func progress(on date: Date) -> Double {
        guard goal > 0 else { return 0 }
        return min(max(Double(count(on: date)) / Double(goal), 0), 1)
    }

    func reachedGoal(on date: Date) -> Bool {
        goal > 0 && count(on: date) >= goal
    }

    var total: Int {
        counts.values.reduce(0, +)
    }

    mutating func step(by delta: Int, on date: Date) {
        let key = DayKey.string(date)
        let next = max((counts[key] ?? 0) + delta, 0)
        counts[key] = next == 0 ? nil : next
    }

    func history(_ days: Int, asOf date: Date) -> [(day: Date, count: Int)] {
        guard days > 0 else { return [] }
        let today = Persian.calendar.startOfDay(for: date)
        return (0..<days).map { offset in
            let day = Persian.shift(today, days: offset - days + 1)
            return (day: day, count: count(on: day))
        }
    }
}
