import Foundation

extension NoteItem: LibraryEntry {
    var entryTitle: String { text.entryFirstLine ?? "یادداشت خالی" }
    var entrySubtitle: String { "ویرایش " + Persian.shortDate(updated) }
    var entryTheme: Theme? { theme }
}

extension CountdownItem: LibraryEntry {
    var entryTitle: String { title.entryName }
    var entrySubtitle: String { CountdownRemaining(date: date).summary }
    var entrySymbol: String? { symbol }
    var entryTheme: Theme? { theme }

    mutating func markAsCopy() {
        title = title.asCopyName
    }
}

extension HabitItem: LibraryEntry {
    var entryTitle: String { title.entryName }
    var entrySymbol: String? { symbol }
    var entryTheme: Theme? { theme }

    var entrySubtitle: String {
        let run = streak(asOf: .now)
        return run == 0 ? "امروز شروعش کن" : Persian.number(run) + " روز پشت سر هم"
    }

    mutating func markAsCopy() {
        title = title.asCopyName
        days = []
    }
}

extension TodoList: LibraryEntry {
    var entryTitle: String { title.entryName }
    var entryTheme: Theme? { theme }

    var entrySubtitle: String {
        if items.isEmpty { return "فهرست خالیه" }
        if remaining == 0 { return "همه‌ی کارها انجام شد" }
        return Persian.number(remaining) + " کار مانده"
    }

    mutating func markAsCopy() {
        title = title.asCopyName
        for index in items.indices {
            items[index].id = UUID().uuidString
            items[index].done = false
        }
    }
}

extension CounterItem: LibraryEntry {
    var entryTitle: String { title.entryName }
    var entrySymbol: String? { symbol }
    var entryTheme: Theme? { theme }

    var entrySubtitle: String {
        let shown = shownCount(on: .now)
        let prefix = dailyReset ? "امروز " : ""
        return prefix + Persian.number(shown) + " از " + Persian.number(goal)
    }

    mutating func markAsCopy() {
        title = title.asCopyName
        counts = [:]
    }
}
