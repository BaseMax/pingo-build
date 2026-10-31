import Foundation

struct CountdownRemaining: Equatable {
    let days: Int

    init(days: Int) {
        self.days = days
    }

    init(date: Date, now: Date = .now) {
        self.init(days: Persian.daysBetween(now, date))
    }

    var number: String {
        Persian.number(abs(days))
    }

    var showsNumber: Bool {
        days != 0
    }

    var phrase: String {
        switch days {
        case 0: "امروزه، وقتشه!"
        case 1...: "روز مانده"
        default: "روز از این رویداد گذشته"
        }
    }

    var summary: String {
        showsNumber ? number + " " + phrase : phrase
    }
}
