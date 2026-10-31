import Foundation

extension CounterItem {
    var shownCount: Int { shownCount(on: .now) }

    var shownProgress: Double { shownProgress(on: .now) }

    var reachedShownGoal: Bool { reachedShownGoal(on: .now) }
}

struct CounterDay: Identifiable {
    let day: Date
    let count: Int

    var id: Date { day }
    var isToday: Bool { Persian.daysBetween(day, .now) == 0 }
}
