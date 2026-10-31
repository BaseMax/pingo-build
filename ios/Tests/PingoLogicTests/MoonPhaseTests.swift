import XCTest
@testable import PingoLogic

final class MoonPhaseTests: XCTestCase {
    private let tolerance: TimeInterval = 120

    private func computed(code: String, near date: Date) -> Date {
        let offset = UsnoMoonEvents.offsets[code] ?? 0
        let base = LunarEvents.approximateIndex(for: date)
        return (-2...2).map { LunarEvents.date(k: base + Double($0) + offset) }.min { abs($0.timeIntervalSince(date)) < abs($1.timeIntervalSince(date)) } ?? date
    }

    func testEveryUsnoEventOf2026And2027IsWithinTwoMinutes() {
        XCTAssertEqual(UsnoMoonEvents.all.count, 99)
        for event in UsnoMoonEvents.all {
            let expected = UsnoMoonEvents.date(event.utc)
            let actual = computed(code: event.code, near: expected)
            XCTAssertEqual(actual.timeIntervalSince(expected), 0, accuracy: tolerance, "\(event.code) \(event.utc)")
        }
    }

    func testFractionAtEventsIsTheQuarterPosition() {
        for event in UsnoMoonEvents.all {
            let at = computed(code: event.code, near: UsnoMoonEvents.date(event.utc))
            let wanted = UsnoMoonEvents.offsets[event.code] ?? 0
            let value = MoonPhase(date: at.addingTimeInterval(1)).fraction
            let distance = min(abs(value - wanted), 1 - abs(value - wanted))
            XCTAssertLessThan(distance, 0.001, "\(event.code) \(event.utc)")
        }
    }

    func testIlluminationAtEvents() {
        for event in UsnoMoonEvents.all {
            let at = computed(code: event.code, near: UsnoMoonEvents.date(event.utc)).addingTimeInterval(1)
            let value = MoonPhase(date: at).illumination
            switch event.code {
            case "n": XCTAssertLessThan(value, 0.001)
            case "u": XCTAssertGreaterThan(value, 0.999)
            default: XCTAssertEqual(value, 0.5, accuracy: 0.01)
            }
        }
    }

    func testNamesAtEvents() {
        let names = ["n": "ماه نو", "f": "تربیع اول", "u": "ماه کامل", "l": "تربیع آخر"]
        for event in UsnoMoonEvents.all {
            let at = computed(code: event.code, near: UsnoMoonEvents.date(event.utc))
            XCTAssertEqual(MoonPhase(date: at.addingTimeInterval(1)).name, names[event.code], event.utc)
            XCTAssertEqual(MoonPhase(date: at.addingTimeInterval(-3600)).name, names[event.code], event.utc)
        }
    }

    func testReferenceNewMoonOfJanuary2000() {
        let expected = UsnoMoonEvents.date("2000-01-06 18:14")
        let actual = LunarEvents.date(k: 0)
        XCTAssertEqual(actual.timeIntervalSince(expected), 0, accuracy: 180)
    }

    func testAgeCountsDaysSinceTheTrueNewMoon() {
        let newMoon = UsnoMoonEvents.date("2026-10-10 15:50")
        XCTAssertEqual(MoonPhase(date: newMoon.addingTimeInterval(3600)).age, 0)
        XCTAssertEqual(MoonPhase(date: newMoon.addingTimeInterval(86400 * 7.4)).age, 7)
        let full = UsnoMoonEvents.date("2026-10-26 04:12")
        XCTAssertEqual(MoonPhase(date: full).age, 16)
    }

    func testAgeNeverExceedsTheMaximum() {
        var date = UsnoMoonEvents.date("2026-01-01 00:00")
        for _ in 0..<800 {
            XCTAssertLessThanOrEqual(MoonPhase(date: date).age, MoonPhase.maxAge)
            date = date.addingTimeInterval(86400 / 3)
        }
    }

    func testFractionStaysInUnitRangeAndIsMonotonicWithinACycle() {
        var date = UsnoMoonEvents.date("2026-03-01 00:00")
        var previous = MoonPhase(date: date).fraction
        for _ in 0..<400 {
            date = date.addingTimeInterval(3600 * 3)
            let value = MoonPhase(date: date).fraction
            XCTAssertTrue(value >= 0 && value < 1)
            XCTAssertTrue(value > previous || previous > 0.9, "\(date)")
            previous = value
        }
    }

    func testIlluminationRisesThenFalls() {
        let newMoon = UsnoMoonEvents.date("2026-10-10 15:50")
        func illumination(_ days: Double) -> Double { MoonPhase(date: newMoon.addingTimeInterval(days * 86400)).illumination }
        XCTAssertLessThan(illumination(3), illumination(7))
        XCTAssertLessThan(illumination(12), illumination(15.2))
        XCTAssertGreaterThan(illumination(18), illumination(25))
    }

    func testNamesAreEightDistinctPhases() {
        XCTAssertEqual(Set(MoonPhase.names).count, 8)
    }

    func testDatesFarFromTodayStillWork() {
        for text in ["1999-06-01 00:00", "2040-06-01 00:00", "2100-01-01 00:00"] {
            let moon = MoonPhase(date: UsnoMoonEvents.date(text))
            XCTAssertTrue(moon.fraction >= 0 && moon.fraction < 1)
            XCTAssertTrue(moon.illumination >= 0 && moon.illumination <= 1)
        }
    }
}
