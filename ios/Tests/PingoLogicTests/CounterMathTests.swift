import XCTest
@testable import PingoLogic

final class CounterMathTests: XCTestCase {
    private func gregorian(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: 12)
        return Calendar(identifier: .gregorian).date(from: components) ?? .distantPast
    }

    func testStepAddsAndSubtracts() {
        Store.backend = MemoryBackend()
        var counter = CounterItem(goal: 8)
        let day = gregorian(2025, 5, 4)
        counter.step(by: 1, on: day)
        counter.step(by: 3, on: day)
        XCTAssertEqual(counter.count(on: day), 4)
        counter.step(by: -1, on: day)
        XCTAssertEqual(counter.count(on: day), 3)
        XCTAssertEqual(counter.counts["2025-05-04"], 3)
    }

    func testStepClampsAtZero() {
        Store.backend = MemoryBackend()
        var counter = CounterItem()
        let day = gregorian(2025, 5, 4)
        counter.step(by: -5, on: day)
        XCTAssertEqual(counter.count(on: day), 0)
        counter.step(by: 2, on: day)
        counter.step(by: -10, on: day)
        XCTAssertEqual(counter.count(on: day), 0)
        XCTAssertTrue(counter.counts.isEmpty)
    }

    func testCountsAreKeyedPerDay() {
        Store.backend = MemoryBackend()
        var counter = CounterItem()
        counter.step(by: 2, on: gregorian(2025, 5, 4))
        counter.step(by: 5, on: gregorian(2025, 5, 5))
        XCTAssertEqual(counter.count(on: gregorian(2025, 5, 4)), 2)
        XCTAssertEqual(counter.count(on: gregorian(2025, 5, 5)), 5)
        XCTAssertEqual(counter.count(on: gregorian(2025, 5, 6)), 0)
    }

    func testDailyResetDoesNotChangeCount() {
        Store.backend = MemoryBackend()
        var counter = CounterItem(dailyReset: false)
        counter.step(by: 2, on: gregorian(2025, 5, 4))
        XCTAssertEqual(counter.count(on: gregorian(2025, 5, 4)), 2)
        XCTAssertEqual(counter.count(on: gregorian(2025, 5, 5)), 0)
    }

    func testProgressIsClamped() {
        Store.backend = MemoryBackend()
        var counter = CounterItem(goal: 4)
        let day = gregorian(2025, 5, 4)
        XCTAssertEqual(counter.progress(on: day), 0)
        counter.step(by: 1, on: day)
        XCTAssertEqual(counter.progress(on: day), 0.25, accuracy: 0.0001)
        counter.step(by: 10, on: day)
        XCTAssertEqual(counter.progress(on: day), 1)
    }

    func testProgressIsZeroWithoutGoal() {
        Store.backend = MemoryBackend()
        var counter = CounterItem(goal: 0)
        counter.step(by: 3, on: gregorian(2025, 5, 4))
        XCTAssertEqual(counter.progress(on: gregorian(2025, 5, 4)), 0)
        XCTAssertFalse(counter.reachedGoal(on: gregorian(2025, 5, 4)))
    }

    func testReachedGoal() {
        Store.backend = MemoryBackend()
        var counter = CounterItem(goal: 2)
        let day = gregorian(2025, 5, 4)
        XCTAssertFalse(counter.reachedGoal(on: day))
        counter.step(by: 1, on: day)
        XCTAssertFalse(counter.reachedGoal(on: day))
        counter.step(by: 1, on: day)
        XCTAssertTrue(counter.reachedGoal(on: day))
        counter.step(by: 5, on: day)
        XCTAssertTrue(counter.reachedGoal(on: day))
    }

    func testTotalSumsAllDays() {
        Store.backend = MemoryBackend()
        var counter = CounterItem()
        XCTAssertEqual(counter.total, 0)
        counter.step(by: 2, on: gregorian(2025, 5, 4))
        counter.step(by: 3, on: gregorian(2025, 5, 5))
        counter.step(by: 4, on: gregorian(2025, 1, 1))
        XCTAssertEqual(counter.total, 9)
    }

    func testHistoryIsOldestToNewestIncludingZeroDays() {
        Store.backend = MemoryBackend()
        var counter = CounterItem()
        counter.step(by: 2, on: gregorian(2025, 5, 2))
        counter.step(by: 7, on: gregorian(2025, 5, 4))
        let history = counter.history(4, asOf: gregorian(2025, 5, 4))
        XCTAssertEqual(history.map { DayKey.string($0.day) }, ["2025-05-01", "2025-05-02", "2025-05-03", "2025-05-04"])
        XCTAssertEqual(history.map(\.count), [0, 2, 0, 7])
        XCTAssertTrue(counter.history(0, asOf: .now).isEmpty)
    }
}
