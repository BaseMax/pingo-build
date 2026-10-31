import XCTest
@testable import PingoLogic

final class SlotClockTests: XCTestCase {
    private var tehran: Calendar {
        var calendar = Calendar(identifier: .persian)
        calendar.timeZone = TimeZone(secondsFromGMT: 12600) ?? .current
        return calendar
    }

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func tehranTime(_ hour: Int, _ minute: Int, day: Int = 10) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 12600) ?? .current
        return calendar.date(from: DateComponents(year: 2026, month: 7, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    func testHourlySlotChangesAtTheLocalTopOfTheHour() {
        let calendar = tehran
        let before = tehranTime(13, 59)
        let after = tehranTime(14, 0)
        XCTAssertEqual(SlotClock.slot(at: after, minutes: 60, calendar: calendar), SlotClock.slot(at: before, minutes: 60, calendar: calendar) + 1)
        XCTAssertEqual(SlotClock.start(of: tehranTime(14, 40), minutes: 60, calendar: calendar), after)
        XCTAssertEqual(SlotClock.next(after: tehranTime(14, 40), minutes: 60, calendar: calendar), tehranTime(15, 0))
    }

    func testDailySlotChangesAtLocalMidnight() {
        let calendar = tehran
        let before = tehranTime(23, 59)
        let after = tehranTime(0, 0, day: 11)
        XCTAssertEqual(SlotClock.slot(at: after, minutes: 1440, calendar: calendar), SlotClock.slot(at: before, minutes: 1440, calendar: calendar) + 1)
        XCTAssertEqual(SlotClock.next(after: tehranTime(12, 0), minutes: 1440, calendar: calendar), after)
    }

    func testUtcMidnightIsNotASlotChangeInTehran() {
        let calendar = tehran
        let utcMidnight = utc.date(from: DateComponents(year: 2026, month: 7, day: 11, hour: 0, minute: 0)) ?? .distantPast
        let a = SlotClock.slot(at: utcMidnight.addingTimeInterval(-60), minutes: 1440, calendar: calendar)
        let b = SlotClock.slot(at: utcMidnight.addingTimeInterval(60), minutes: 1440, calendar: calendar)
        XCTAssertEqual(a, b)
    }

    func testSlotsAreConsecutiveAcrossMidnight() {
        let calendar = tehran
        var previous = SlotClock.slot(at: tehranTime(22, 0), minutes: 180, calendar: calendar)
        for hour in [23, 24, 25, 27, 30, 33] {
            let date = tehranTime(22, 0).addingTimeInterval(Double(hour - 22) * 3600)
            let slot = SlotClock.slot(at: date, minutes: 180, calendar: calendar)
            XCTAssertGreaterThanOrEqual(slot, previous)
            XCTAssertLessThanOrEqual(slot - previous, 1)
            previous = slot
        }
    }

    func testIntervalNotDividingTheDayRestartsAtMidnight() {
        let calendar = tehran
        let last = SlotClock.start(of: tehranTime(23, 50), minutes: 500, calendar: calendar)
        XCTAssertEqual(last, tehranTime(16, 40))
        XCTAssertEqual(SlotClock.next(after: tehranTime(23, 50), minutes: 500, calendar: calendar), tehranTime(0, 0, day: 11))
    }

    func testBoundariesAreAscendingAndAligned() {
        let calendar = tehran
        let boundaries = SlotClock.boundaries(after: tehranTime(10, 7), minutes: 30, count: 5, calendar: calendar)
        XCTAssertEqual(boundaries, [tehranTime(10, 30), tehranTime(11, 0), tehranTime(11, 30), tehranTime(12, 0), tehranTime(12, 30)])
    }

    func testDegenerateIntervalIsClamped() {
        XCTAssertEqual(SlotClock.slotsPerDay(minutes: 0), 1440)
        XCTAssertEqual(SlotClock.step(minutes: -4), 60)
    }

    func testPhotoPickMatchesTimelineEntriesInTehran() {
        let calendar = tehran
        let now = tehranTime(9, 41)
        let plan = Refresh.slideshow(minutes: 60, count: 24).plan(from: now, calendar: calendar)
        for date in plan.dates {
            XCTAssertEqual(SlotClock.start(of: date, minutes: 60, calendar: calendar), date)
        }
        let slots = plan.dates.map { SlotClock.slot(at: $0, minutes: 60, calendar: calendar) }
        XCTAssertEqual(slots, (0..<24).map { slots[0] + $0 })
        XCTAssertEqual(SlotClock.slot(at: now, minutes: 60, calendar: calendar), slots[0])
    }

    func testPersianCalendarFollowsTheSystemTimeZone() {
        XCTAssertEqual(Persian.calendar.timeZone, TimeZone.autoupdatingCurrent)
    }
}
