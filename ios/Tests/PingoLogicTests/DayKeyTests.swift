import XCTest
@testable import PingoLogic

final class DayKeyTests: XCTestCase {
    private func gregorian(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour)
        return Calendar(identifier: .gregorian).date(from: components) ?? .distantPast
    }

    func testStringIsZeroPaddedGregorian() {
        XCTAssertEqual(DayKey.string(gregorian(2025, 3, 5)), "2025-03-05")
        XCTAssertEqual(DayKey.string(gregorian(2024, 12, 31, hour: 23)), "2024-12-31")
        XCTAssertEqual(DayKey.string(gregorian(2025, 1, 1, hour: 0)), "2025-01-01")
    }

    func testStringIgnoresPersianCalendar() {
        let nowruz = gregorian(2025, 3, 21)
        XCTAssertEqual(Persian.calendar.component(.year, from: nowruz), 1404)
        XCTAssertEqual(Persian.calendar.component(.day, from: nowruz), 1)
        XCTAssertEqual(DayKey.string(nowruz), "2025-03-21")
    }

    func testDateRoundTrip() {
        let key = "2025-04-21"
        XCTAssertEqual(DayKey.date(key).map(DayKey.string), key)
    }

    func testDateRejectsMalformedKeys() {
        XCTAssertNil(DayKey.date("garbage"))
        XCTAssertNil(DayKey.date("2025-3-5"))
        XCTAssertNil(DayKey.date(""))
    }
}
