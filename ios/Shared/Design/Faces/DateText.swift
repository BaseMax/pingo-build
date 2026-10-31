import Foundation

enum DateText {
    private static let gregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        return calendar
    }()
    private static let gregorianLocale = Locale(identifier: "en_US_POSIX")

    static func gregorian(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = gregorianCalendar
        formatter.timeZone = gregorianCalendar.timeZone
        formatter.locale = gregorianLocale
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    static func monthYear(_ date: Date) -> String {
        Persian.format(date, "MMMM y")
    }

    static func inline(_ date: Date) -> String {
        Persian.weekdayName(date) + " " + Persian.shortDate(date)
    }
}
