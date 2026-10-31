import XCTest
@testable import PingoLogic

final class HabitMathTests: XCTestCase {
    private func gregorian(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: 12)
        return Calendar(identifier: .gregorian).date(from: components) ?? .distantPast
    }

    private func persianParts(_ date: Date) -> [Int] {
        [.year, .month, .day].map { Persian.calendar.component($0, from: date) }
    }

    private func habit(_ keys: [String]) -> HabitItem {
        HabitItem(title: "t", days: Set(keys))
    }

    func testToggleIsAnInvolution() {
        Store.backend = MemoryBackend()
        var item = HabitItem()
        let day = gregorian(2025, 5, 1)
        XCTAssertFalse(item.isDone(day))
        item.toggle(day)
        XCTAssertTrue(item.isDone(day))
        XCTAssertEqual(item.days, ["2025-05-01"])
        item.toggle(day)
        XCTAssertFalse(item.isDone(day))
        XCTAssertTrue(item.days.isEmpty)
    }

    func testIsDoneIgnoresTimeOfDay() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-05-01"])
        XCTAssertTrue(item.isDone(gregorian(2025, 5, 1).addingTimeInterval(3600)))
        XCTAssertTrue(item.isDone(gregorian(2025, 5, 1).addingTimeInterval(-3600)))
    }

    func testStreakCountsBackFromToday() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-05-01", "2025-05-02", "2025-05-03", "2025-04-28"])
        XCTAssertEqual(item.streak(asOf: gregorian(2025, 5, 3)), 3)
    }

    func testStreakStartsFromYesterdayWhenTodayNotDone() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-05-01", "2025-05-02"])
        XCTAssertEqual(item.streak(asOf: gregorian(2025, 5, 3)), 2)
    }

    func testStreakBreaksAfterAMissedDay() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-05-01", "2025-05-02"])
        XCTAssertEqual(item.streak(asOf: gregorian(2025, 5, 4)), 0)
        XCTAssertEqual(HabitItem().streak(asOf: gregorian(2025, 5, 4)), 0)
    }

    func testStreakAcrossPersianMonthBoundary() {
        Store.backend = MemoryBackend()
        let item = habit(["2024-10-20", "2024-10-21", "2024-10-22", "2024-10-23"])
        XCTAssertEqual(persianParts(gregorian(2024, 10, 21)), [1403, 7, 30])
        XCTAssertEqual(persianParts(gregorian(2024, 10, 22)), [1403, 8, 1])
        XCTAssertEqual(item.streak(asOf: gregorian(2024, 10, 23)), 4)
        XCTAssertEqual(item.bestStreak(), 4)
    }

    func testStreakAcrossPersianYearBoundary() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-03-19", "2025-03-20", "2025-03-21", "2025-03-22"])
        XCTAssertEqual(persianParts(gregorian(2025, 3, 20)), [1403, 12, 30])
        XCTAssertEqual(persianParts(gregorian(2025, 3, 21)), [1404, 1, 1])
        XCTAssertEqual(item.streak(asOf: gregorian(2025, 3, 22)), 4)
        XCTAssertEqual(item.streak(asOf: gregorian(2025, 3, 23)), 4)
        XCTAssertEqual(item.bestStreak(), 4)
    }

    func testStreakAcrossGregorianYearBoundary() {
        Store.backend = MemoryBackend()
        let item = habit(["2024-12-30", "2024-12-31", "2025-01-01"])
        XCTAssertEqual(item.streak(asOf: gregorian(2025, 1, 1)), 3)
    }

    func testBestStreakPicksLongestRun() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-01-01", "2025-01-02", "2025-02-10", "2025-02-11", "2025-02-12", "2025-03-01"])
        XCTAssertEqual(item.bestStreak(), 3)
        XCTAssertEqual(HabitItem().bestStreak(), 0)
        XCTAssertEqual(habit(["2025-01-01"]).bestStreak(), 1)
    }

    func testBestStreakIgnoresInvalidKeys() {
        Store.backend = MemoryBackend()
        XCTAssertEqual(habit(["junk", "2025-01-01", "2025-01-02"]).bestStreak(), 2)
    }

    func testRateIsDoneDaysOverWindow() {
        Store.backend = MemoryBackend()
        let item = habit(["2025-05-01", "2025-05-03", "2025-05-04", "2025-04-01"])
        let today = gregorian(2025, 5, 4)
        XCTAssertEqual(item.rate(lastDays: 4, asOf: today), 0.75, accuracy: 0.0001)
        XCTAssertEqual(item.rate(lastDays: 2, asOf: today), 1, accuracy: 0.0001)
        XCTAssertEqual(item.rate(lastDays: 10, asOf: today), 0.3, accuracy: 0.0001)
        XCTAssertEqual(item.rate(lastDays: 0, asOf: today), 0)
    }

    func testLastDaysRunOldestToNewestEndingToday() {
        Store.backend = MemoryBackend()
        let days = HabitItem().lastDays(3, asOf: gregorian(2025, 5, 4))
        XCTAssertEqual(days.map(DayKey.string), ["2025-05-02", "2025-05-03", "2025-05-04"])
        XCTAssertTrue(HabitItem().lastDays(0, asOf: .now).isEmpty)
    }

    func testLastDaysCrossYearBoundary() {
        Store.backend = MemoryBackend()
        let days = HabitItem().lastDays(3, asOf: gregorian(2025, 3, 21))
        XCTAssertEqual(days.map(persianParts), [[1403, 12, 29], [1403, 12, 30], [1404, 1, 1]])
    }
}
