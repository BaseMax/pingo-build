import Foundation

struct ProgressSlice: Identifiable {
    let id: Int
    let title: String
    let value: Double

    var percent: String { Persian.percent(value) }

    static func all(at date: Date) -> [ProgressSlice] {
        let titles = ["روز", "هفته", "ماه", "سال"]
        let components: [Calendar.Component] = [.day, .weekOfYear, .month, .year]
        return zip(titles, components).enumerated().map { index, pair in
            ProgressSlice(id: index, title: pair.0, value: Persian.fraction(pair.1, at: date))
        }
    }
}
