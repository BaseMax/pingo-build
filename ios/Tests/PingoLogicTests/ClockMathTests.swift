import XCTest
@testable import PingoLogic

final class ClockMathTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 12600) ?? .current
        return calendar
    }()

    private func time(_ hour: Int, _ minute: Int) -> Date {
        calendar.date(from: DateComponents(year: 2025, month: 6, day: 15, hour: hour, minute: minute)) ?? .distantPast
    }

    func testTwelveOClockPointsStraightUp() {
        XCTAssertEqual(ClockMath.hourAngle(time(12, 0), calendar: calendar), 0, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(time(0, 0), calendar: calendar), 0, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.minuteAngle(time(12, 0), calendar: calendar), 0, accuracy: 1e-9)
    }

    func testHourAngleStepsThirtyDegreesPerHour() {
        XCTAssertEqual(ClockMath.hourAngle(time(3, 0), calendar: calendar), 90, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(time(6, 0), calendar: calendar), 180, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(time(15, 0), calendar: calendar), 90, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(time(23, 0), calendar: calendar), 330, accuracy: 1e-9)
    }

    func testHourAngleIncludesTheMinuteFraction() {
        XCTAssertEqual(ClockMath.hourAngle(time(3, 30), calendar: calendar), 105, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(time(10, 10), calendar: calendar), 305, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(time(11, 59), calendar: calendar), 359.5, accuracy: 1e-9)
    }

    func testMinuteAngleStepsSixDegreesPerMinute() {
        XCTAssertEqual(ClockMath.minuteAngle(time(4, 15), calendar: calendar), 90, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.minuteAngle(time(4, 30), calendar: calendar), 180, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.minuteAngle(time(4, 45), calendar: calendar), 270, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.minuteAngle(time(4, 59), calendar: calendar), 354, accuracy: 1e-9)
    }

    func testCalendarTimeZoneIsRespected() {
        let instant = time(9, 0)
        var utc = calendar
        utc.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        XCTAssertEqual(ClockMath.hourAngle(instant, calendar: calendar), 270, accuracy: 1e-9)
        XCTAssertEqual(ClockMath.hourAngle(instant, calendar: utc), 165, accuracy: 1e-9)
    }

    func testDigitalPadsMinutesWithPersianDigits() {
        XCTAssertEqual(ClockMath.digital(time(10, 5), calendar: calendar), "۱۰:۰۵")
        XCTAssertEqual(ClockMath.digital(time(9, 0), calendar: calendar), "۹:۰۰")
        XCTAssertEqual(ClockMath.digital(time(0, 7), calendar: calendar), "۰:۰۷")
        XCTAssertEqual(ClockMath.digital(time(23, 59), calendar: calendar), "۲۳:۵۹")
        XCTAssertEqual(ClockMath.digital(time(12, 30), calendar: calendar), "۱۲:۳۰")
    }
}
