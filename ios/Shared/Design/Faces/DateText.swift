import Foundation

enum DateText {
    private static let gregorianCalendar = Calendar(identifier: .gregorian)
    private static let gregorianLocale = Locale(identifier: "en_US_POSIX")

    static func gregorian(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = gregorianCalendar
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
