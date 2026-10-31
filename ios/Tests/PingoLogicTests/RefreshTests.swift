import XCTest
@testable import PingoLogic

final class RefreshTests: XCTestCase {
    private let noon = Persian.calendar.date(from: DateComponents(year: 1404, month: 5, day: 10, hour: 12, minute: 17, second: 42)) ?? .distantPast

    func testMidnightPlanHasNowAndNextPersianMidnight() {
        let plan = Refresh.midnight.plan(from: noon)
        let boundary = Persian.calendar.startOfDay(for: Persian.shift(noon, days: 1))
        XCTAssertEqual(plan.dates, [noon, boundary])
        XCTAssertEqual(plan.reload, boundary.addingTimeInterval(60))
        XCTAssertTrue(boundary > noon)
        XCTAssertEqual(Persian.dayNumber(boundary), 11)
    }

    func testMidnightPlanJustBeforeMidnightStillTargetsNextDay() {
        let late = Persian.calendar.date(from: DateComponents(year: 1404, month: 5, day: 10, hour: 23, minute: 59, second: 30)) ?? .distantPast
        let plan = Refresh.midnight.plan(from: late)
        XCTAssertEqual(plan.dates.count, 2)
        XCTAssertEqual(plan.dates[1].timeIntervalSince(late), 30, accuracy: 1)
    }

    private var tehran: Calendar {
        var calendar = Calendar(identifier: .persian)
        calendar.timeZone = TimeZone(secondsFromGMT: 12600) ?? .current
        return calendar
    }

    private func tehranTime(_ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 12600) ?? .current
        return calendar.date(from: DateComponents(year: 2026, month: 7, day: 10, hour: hour, minute: minute, second: second)) ?? .distantPast
    }

    func testEveryMinutesPlanEmitsOneEntryPerBoundary() {
        let now = tehranTime(10, 7, 20)
        let plan = Refresh.every(minutes: 30).plan(from: now, calendar: tehran)
        XCTAssertEqual(plan.dates.count, Refresh.everyEntries)
        XCTAssertEqual(plan.dates[0], now)
        XCTAssertEqual(plan.dates[1], tehranTime(10, 30))
        XCTAssertEqual(plan.dates[2], tehranTime(11, 0))
        XCTAssertEqual(plan.dates[11], tehranTime(15, 30))
        XCTAssertEqual(plan.reload, tehranTime(16, 0))
    }

    func testEveryTwoHoursAlignsToLocalEvenHours() {
        let now = tehranTime(9, 41)
        let plan = Refresh.every(minutes: 120).plan(from: now, calendar: tehran)
        XCTAssertEqual(plan.dates[1], tehranTime(10, 0))
        XCTAssertEqual(plan.dates[2], tehranTime(12, 0))
        XCTAssertEqual(plan.dates.count, 12)
        XCTAssertEqual(plan.reload, plan.dates[11].addingTimeInterval(7200))
    }

    func testEveryPlanStopsAtMidnightBoundaryWithoutSkippingIt() {
        let now = tehranTime(23, 10)
        let plan = Refresh.every(minutes: 30).plan(from: now, calendar: tehran)
        XCTAssertEqual(plan.dates[1], tehranTime(23, 30))
        XCTAssertEqual(plan.dates[2], tehranTime(23, 30).addingTimeInterval(1800))
        XCTAssertEqual(plan.dates[2].timeIntervalSince(plan.dates[1]), 1800)
    }

    func testEveryMinutesNeverBelowOne() {
        for minutes in [0, -5] {
            let plan = Refresh.every(minutes: minutes).plan(from: noon)
            XCTAssertEqual(plan.dates.count, Refresh.everyEntries)
            XCTAssertEqual(plan.dates[2].timeIntervalSince(plan.dates[1]), 60)
            XCTAssertEqual(plan.reload.timeIntervalSince(plan.dates[11]), 60)
        }
    }

    func testSlideshowHourlyStepsAreAlignedToLocalHours() {
        let plan = Refresh.slideshow(minutes: 60, count: 6).plan(from: tehranTime(9, 41), calendar: tehran)
        XCTAssertEqual(plan.dates, (9...14).map { tehranTime($0, 0) })
        XCTAssertEqual(plan.reload, tehranTime(15, 0))
    }

    func testSlideshowDailyStepsChangeAtLocalMidnight() {
        let plan = Refresh.slideshow(minutes: 1440, count: 3).plan(from: tehranTime(15, 5), calendar: tehran)
        XCTAssertEqual(plan.dates[0], tehranTime(0, 0))
        XCTAssertEqual(plan.dates[1].timeIntervalSince(plan.dates[0]), 86400)
        XCTAssertEqual(plan.dates[2].timeIntervalSince(plan.dates[1]), 86400)
        XCTAssertEqual(plan.reload, plan.dates[2].addingTimeInterval(86400))
    }

    func testMidnightPlanFollowsTheGivenCalendar() {
        let plan = Refresh.midnight.plan(from: tehranTime(15, 5), calendar: tehran)
        XCTAssertEqual(plan.dates[1].timeIntervalSince(tehranTime(0, 0)), 86400)
    }

    func testMinutelyPlanIsAlignedAndOrdered() {
        let plan = Refresh.minutely(count: 60).plan(from: noon)
        XCTAssertEqual(plan.dates.count, 60)
        XCTAssertEqual(plan.dates[0].timeIntervalSince1970.truncatingRemainder(dividingBy: 60), 0)
        XCTAssertTrue(plan.dates[0] <= noon)
        XCTAssertTrue(noon.timeIntervalSince(plan.dates[0]) < 60)
        for pair in zip(plan.dates, plan.dates.dropFirst()) {
            XCTAssertEqual(pair.1.timeIntervalSince(pair.0), 60)
        }
        XCTAssertEqual(plan.reload, plan.dates[0].addingTimeInterval(3600))
    }

    func testSlideshowPlanAlignsToTheInterval() {
        let plan = Refresh.slideshow(minutes: 15, count: 24).plan(from: noon)
        XCTAssertEqual(plan.dates.count, 24)
        XCTAssertEqual(plan.dates[0].timeIntervalSince1970.truncatingRemainder(dividingBy: 900), 0)
        XCTAssertTrue(plan.dates[0] <= noon && noon.timeIntervalSince(plan.dates[0]) < 900)
        XCTAssertEqual(plan.dates[23].timeIntervalSince(plan.dates[0]), 23 * 900)
        XCTAssertEqual(plan.reload, plan.dates[0].addingTimeInterval(24 * 900))
    }

    func testSlideshowPlanClampsDegenerateValues() {
        let plan = Refresh.slideshow(minutes: 0, count: 0).plan(from: noon)
        XCTAssertEqual(plan.dates.count, 1)
        XCTAssertEqual(plan.reload.timeIntervalSince(plan.dates[0]), 60)
        XCTAssertEqual(Refresh.minutely(count: -3).plan(from: noon).dates.count, 1)
    }

    func testReloadIsAlwaysAfterTheLastEntry() {
        let refreshes: [Refresh] = [.midnight, .every(minutes: 5), .minutely(count: 10), .slideshow(minutes: 60, count: 6)]
        for refresh in refreshes {
            let plan = refresh.plan(from: noon)
            XCTAssertTrue(plan.reload > (plan.dates.last ?? noon), "\(refresh)")
            XCTAssertEqual(plan.dates, plan.dates.sorted())
        }
    }

    func testKindRefreshMapping() {
        XCTAssertEqual(PingoKind.progress.refresh(), .every(minutes: 30))
        XCTAssertEqual(PingoKind.moon.refresh(), .every(minutes: 120))
        XCTAssertEqual(PingoKind.clock.refresh(), .minutely(count: 60))
        for kind in [PingoKind.date, .countdown, .note, .todo, .habit, .counter, .fal] {
            XCTAssertEqual(kind.refresh(), .midnight, kind.rawValue)
        }
    }

    func testPhotoRefreshFollowsAlbumMinutes() {
        XCTAssertEqual(PingoKind.photo.refresh(), .slideshow(minutes: 60, count: 24))
        XCTAssertEqual(PingoKind.photo.refresh(albumMinutes: 15), .slideshow(minutes: 15, count: 24))
        XCTAssertEqual(PingoKind.photo.refresh(albumMinutes: 1440), .slideshow(minutes: 1440, count: 24))
        XCTAssertEqual(PingoKind.photo.refresh(albumMinutes: 0), .slideshow(minutes: 1, count: 24))
        XCTAssertEqual(PingoKind.photo.refresh(albumMinutes: -9), .slideshow(minutes: 1, count: 24))
    }

    func testAlbumMinutesIgnoredByOtherKinds() {
        XCTAssertEqual(PingoKind.date.refresh(albumMinutes: 5), .midnight)
        XCTAssertEqual(PingoKind.clock.refresh(albumMinutes: 5), .minutely(count: 60))
    }
}
