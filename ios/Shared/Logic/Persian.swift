import Foundation

enum Persian {
    static let locale = Locale(identifier: "fa_IR")

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .persian)
        calendar.locale = locale
        calendar.timeZone = .autoupdatingCurrent
        calendar.firstWeekday = 7
        return calendar
    }()

    static func format(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = locale
        formatter.dateFormat = pattern
        return formatter.string(from: date)
    }

    static func number(_ value: Int) -> String {
        value.formatted(.number.locale(locale))
    }

    static func percent(_ fraction: Double) -> String {
        "٪" + number(Int((fraction * 100).rounded(.down)))
    }

    static func shift(_ date: Date, days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date.addingTimeInterval(Double(days) * 86400)
    }

    static func dayNumber(_ date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    static func fraction(_ component: Calendar.Component, at date: Date) -> Double {
        guard let interval = calendar.dateInterval(of: component, for: date), interval.duration > 0 else { return 0 }
        return date.timeIntervalSince(interval.start) / interval.duration
    }

    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: from), to: calendar.startOfDay(for: to)).day ?? 0
    }

    static func monthCells(for date: Date) -> [Int?] {
        guard let interval = calendar.dateInterval(of: .month, for: date),
              let days = calendar.range(of: .day, in: .month, for: date) else { return [] }
        return Array<Int?>(repeating: nil, count: weekdayOffset(interval.start)) + days.map { Int?.some($0) }
    }

    static let weekdayLetters = ["ش", "ی", "د", "س", "چ", "پ", "ج"]

    static func weekdayOffset(_ date: Date) -> Int {
        (calendar.component(.weekday, from: date) - calendar.firstWeekday + 7) % 7
    }

    static func weekdayLetter(_ date: Date) -> String {
        weekdayLetters[weekdayOffset(date)]
    }

    static func weekdayName(_ date: Date) -> String {
        format(date, "EEEE")
    }

    static func monthName(_ date: Date) -> String {
        format(date, "MMMM")
    }

    static func monthTitle(_ date: Date) -> String {
        format(date, "MMMM y")
    }

    static func shortDate(_ date: Date) -> String {
        format(date, "d MMMM")
    }

    static func relativeDay(_ date: Date, from now: Date = .now) -> String {
        let days = daysBetween(now, date)
        switch days {
        case 0: return "امروز"
        case 1: return "فردا"
        case -1: return "دیروز"
        case 2...: return number(days) + " روز دیگه"
        default: return number(-days) + " روز پیش"
        }
    }
}
