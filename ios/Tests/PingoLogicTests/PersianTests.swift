import XCTest
@testable import PingoLogic

final class PersianTests: XCTestCase {
    private let persianDigits = Set("۰۱۲۳۴۵۶۷۸۹")

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        let parts = DateComponents(year: year, month: month, day: day, hour: hour)
        return Persian.calendar.date(from: parts) ?? .distantPast
    }

    private func digits(_ text: String) -> String {
        String(text.filter { persianDigits.contains($0) })
    }

    func testCalendarSetup() {
        XCTAssertEqual(Persian.calendar.identifier, .persian)
        XCTAssertEqual(Persian.calendar.firstWeekday, 7)
    }

    func testNowruzFallsOnMarchTwentyFirstIn1404() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = Persian.calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day], from: date(1404, 1, 1))
        XCTAssertEqual(parts.year, 2025)
        XCTAssertEqual(parts.month, 3)
        XCTAssertEqual(parts.day, 21)
    }

    func testDayNumber() {
        XCTAssertEqual(Persian.dayNumber(date(1404, 5, 17)), 17)
        XCTAssertEqual(Persian.dayNumber(date(1404, 12, 1)), 1)
    }

    func testShiftMovesByCalendarDays() {
        let start = date(1404, 6, 31)
        let next = Persian.shift(start, days: 1)
        XCTAssertEqual(Persian.dayNumber(next), 1)
        XCTAssertEqual(Persian.calendar.component(.month, from: next), 7)
        XCTAssertEqual(Persian.shift(next, days: -1), start)
    }

    func testMonthCellsForEveryWeekdayOffset() {
        var seen = Set<Int>()
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = Persian.calendar.timeZone
        for year in 1400...1405 {
            for month in 1...12 {
                let first = date(year, month, 1)
                let cells = Persian.monthCells(for: first)
                let lead = gregorian.component(.weekday, from: first) % 7
                let length = Persian.calendar.range(of: .day, in: .month, for: first)?.count ?? 0
                XCTAssertEqual(cells.count, lead + length)
                XCTAssertTrue(cells.prefix(lead).allSatisfy { $0 == nil })
                XCTAssertEqual(cells.compactMap { $0 }, Array(1...length))
                seen.insert(lead)
            }
        }
        XCTAssertEqual(seen, Set(0...6))
    }

    func testMonthCellsAreIdenticalForAnyDayInTheMonth() {
        XCTAssertEqual(Persian.monthCells(for: date(1404, 3, 1)), Persian.monthCells(for: date(1404, 3, 30, hour: 23)))
    }

    func testMonthLengths() {
        XCTAssertEqual(Persian.monthCells(for: date(1404, 1, 1)).compactMap { $0 }.count, 31)
        XCTAssertEqual(Persian.monthCells(for: date(1404, 6, 1)).compactMap { $0 }.count, 31)
        XCTAssertEqual(Persian.monthCells(for: date(1404, 7, 1)).compactMap { $0 }.count, 30)
        XCTAssertEqual(Persian.monthCells(for: date(1404, 11, 1)).compactMap { $0 }.count, 30)
    }

    func testDaysBetweenSameDayIgnoresTime() {
        XCTAssertEqual(Persian.daysBetween(date(1404, 4, 10, hour: 1), date(1404, 4, 10, hour: 23)), 0)
    }

    func testDaysBetweenAcrossMonthEnds() {
        for month in 1...11 {
            let first = date(1404, month, 1)
            let length = Persian.calendar.range(of: .day, in: .month, for: first)?.count ?? 0
            let last = date(1404, month, length)
            XCTAssertEqual(Persian.daysBetween(last, date(1404, month + 1, 1)), 1)
            XCTAssertEqual(Persian.daysBetween(date(1404, month + 1, 1), last), -1)
            XCTAssertEqual(Persian.daysBetween(first, date(1404, month + 1, 1)), length)
        }
    }

    func testDaysBetweenAcrossYearEnd() {
        let length = Persian.calendar.range(of: .day, in: .month, for: date(1404, 12, 1))?.count ?? 0
        XCTAssertEqual(Persian.daysBetween(date(1404, 12, length), date(1405, 1, 1)), 1)
        XCTAssertEqual(Persian.daysBetween(date(1404, 1, 1), date(1405, 1, 1)), 365)
    }

    func testFractionOfDay() {
        XCTAssertEqual(Persian.fraction(.day, at: date(1404, 4, 10, hour: 0)), 0, accuracy: 1e-9)
        XCTAssertEqual(Persian.fraction(.day, at: date(1404, 4, 10, hour: 12)), 0.5, accuracy: 1e-9)
        XCTAssertEqual(Persian.fraction(.day, at: date(1404, 4, 10, hour: 18)), 0.75, accuracy: 1e-9)
    }

    func testFractionOfMonth() {
        XCTAssertEqual(Persian.fraction(.month, at: date(1404, 2, 1, hour: 0)), 0, accuracy: 1e-9)
        XCTAssertEqual(Persian.fraction(.month, at: date(1404, 2, 16)), 0.5, accuracy: 1e-9)
        XCTAssertEqual(Persian.fraction(.month, at: date(1404, 8, 16)), 15.5 / 30, accuracy: 1e-9)
    }

    func testFractionOfYear() {
        XCTAssertEqual(Persian.fraction(.year, at: date(1404, 1, 1, hour: 0)), 0, accuracy: 1e-9)
        XCTAssertEqual(Persian.fraction(.year, at: date(1404, 7, 1, hour: 0)), 186.0 / 365, accuracy: 1e-9)
        let late = Persian.fraction(.year, at: date(1404, 12, 29, hour: 23))
        XCTAssertTrue(late > 0.99 && late < 1)
    }

    func testNumberUsesPersianDigits() {
        XCTAssertEqual(Persian.number(0), "۰")
        XCTAssertEqual(Persian.number(7), "۷")
        XCTAssertEqual(Persian.number(42), "۴۲")
        XCTAssertEqual(digits(Persian.number(1405)), "۱۴۰۵")
        XCTAssertEqual(digits(Persian.number(1234567)), "۱۲۳۴۵۶۷")
    }

    func testNumberOfNegativeValuesKeepsDigits() {
        XCTAssertEqual(digits(Persian.number(-12)), "۱۲")
    }

    func testPercentUsesPersianDigitsAndRoundsDown() {
        XCTAssertTrue(Persian.percent(0.5).hasPrefix("٪"))
        XCTAssertEqual(digits(Persian.percent(0.5)), "۵۰")
        XCTAssertEqual(digits(Persian.percent(0.999)), "۹۹")
        XCTAssertEqual(digits(Persian.percent(0)), "۰")
        XCTAssertEqual(digits(Persian.percent(1)), "۱۰۰")
    }

    func testFormatProducesPersianMonthAndDigits() {
        let text = Persian.format(date(1404, 1, 5), "d MMMM")
        XCTAssertEqual(digits(text), "۵")
        XCTAssertTrue(text.contains("فروردین"))
    }

    func testWeekdayLettersStartOnSaturday() {
        XCTAssertEqual(Persian.weekdayLetters.count, 7)
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = Persian.calendar.timeZone
        let saturday = (1...7).compactMap { Persian.calendar.date(byAdding: .day, value: $0, to: date(1404, 1, 1)) }
            .first { gregorian.component(.weekday, from: $0) == 7 }
        XCTAssertEqual(saturday.map(Persian.weekdayLetter), "ش")
        XCTAssertEqual(saturday.map(Persian.weekdayOffset), 0)
    }

    func testWeekdayLetterCyclesThroughTheWeek() {
        let start = date(1404, 3, 1)
        let letters = (0..<7).map { Persian.weekdayLetter(Persian.shift(start, days: $0)) }
        XCTAssertEqual(Set(letters), Set(Persian.weekdayLetters))
        XCTAssertEqual(Persian.weekdayLetter(start), Persian.weekdayLetter(Persian.shift(start, days: 7)))
    }

    func testMonthTitleAndShortDateContainMonthName() {
        let day = date(1404, 7, 12)
        XCTAssertTrue(Persian.monthName(day).contains("مهر"))
        XCTAssertTrue(Persian.monthTitle(day).contains("مهر"))
        XCTAssertTrue(Persian.shortDate(day).contains("مهر"))
        XCTAssertEqual(digits(Persian.shortDate(day)), "۱۲")
        XCTAssertFalse(Persian.weekdayName(day).isEmpty)
    }

    func testRelativeDayWording() {
        let now = date(1404, 5, 10)
        XCTAssertEqual(Persian.relativeDay(now, from: now), "امروز")
        XCTAssertEqual(Persian.relativeDay(Persian.shift(now, days: 1), from: now), "فردا")
        XCTAssertEqual(Persian.relativeDay(Persian.shift(now, days: -1), from: now), "دیروز")
        XCTAssertEqual(Persian.relativeDay(Persian.shift(now, days: 5), from: now), "۵ روز دیگه")
        XCTAssertEqual(Persian.relativeDay(Persian.shift(now, days: -3), from: now), "۳ روز پیش")
    }
}
