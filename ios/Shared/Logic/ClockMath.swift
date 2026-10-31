import Foundation

enum ClockMath {
    static func hourAngle(_ date: Date, calendar: Calendar) -> Double {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let hours = Double((parts.hour ?? 0) % 12) + Double(parts.minute ?? 0) / 60
        return hours * 30
    }

    static func minuteAngle(_ date: Date, calendar: Calendar) -> Double {
        Double(calendar.component(.minute, from: date)) * 6
    }

    static func digital(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let minute = parts.minute ?? 0
        let padding = minute < 10 ? Persian.number(0) : ""
        return Persian.number(parts.hour ?? 0) + ":" + padding + Persian.number(minute)
    }
}
