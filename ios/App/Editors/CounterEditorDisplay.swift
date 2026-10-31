import Foundation

extension CounterItem {
    var shownCount: Int {
        dailyReset ? count(on: .now) : total
    }

    var shownProgress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(shownCount) / Double(goal), 1)
    }

    var reachedShownGoal: Bool {
        goal > 0 && shownCount >= goal
    }
}

struct CounterDay: Identifiable {
    let day: Date
    let count: Int

    var id: Date { day }
    var isToday: Bool { Persian.daysBetween(day, .now) == 0 }
}
