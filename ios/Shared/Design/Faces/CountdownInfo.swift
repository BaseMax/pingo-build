import Foundation

struct CountdownInfo {
    static let horizon = 30

    let item: CountdownItem
    let days: Int

    init(item: CountdownItem, date: Date) {
        self.item = item
        days = Persian.daysBetween(date, item.date)
    }

    var isToday: Bool { days == 0 }
    var isPast: Bool { days < 0 }
    var symbol: String { item.symbol }
    var title: String { item.title.isEmpty ? "رویداد" : item.title }
    var number: String { Persian.number(abs(days)) }
    var caption: String { isPast ? "روز گذشته" : "روز مانده" }
    var dateText: String { Persian.format(item.date, "d MMMM y") }

    var progress: Double {
        guard !isPast else { return 1 }
        return 1 - Double(min(days, Self.horizon)) / Double(Self.horizon)
    }

    var inlineText: String {
        if isToday { return "امروز، " + title }
        if isPast { return number + " روز از " + title + " گذشته" }
        return number + " روز تا " + title
    }
}
