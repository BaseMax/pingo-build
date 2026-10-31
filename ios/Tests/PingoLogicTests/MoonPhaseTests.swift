import XCTest
@testable import PingoLogic

final class MoonPhaseTests: XCTestCase {
    private let newMoon = Date(timeIntervalSince1970: MoonPhase.reference)

    private func phase(afterDays days: Double) -> MoonPhase {
        MoonPhase(date: newMoon.addingTimeInterval(days * 86400))
    }

    func testReferenceIsTheNewMoonOfJanuary2000() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: newMoon)
        XCTAssertEqual(parts.year, 2000)
        XCTAssertEqual(parts.month, 1)
        XCTAssertEqual(parts.day, 6)
        XCTAssertEqual(parts.hour, 18)
        XCTAssertEqual(parts.minute, 14)
    }

    func testFractionStaysInUnitRange() {
        for offset in stride(from: -4000.0, through: 4000.0, by: 7.3) {
            let value = phase(afterDays: offset).fraction
            XCTAssertTrue(value >= 0 && value < 1, "offset \(offset) gave \(value)")
        }
    }

    func testIlluminationStaysInUnitRange() {
        for offset in stride(from: 0.0, through: 60.0, by: 0.5) {
            let value = phase(afterDays: offset).illumination
            XCTAssertTrue(value >= 0 && value <= 1)
        }
    }

    func testNewMoon() {
        let moon = phase(afterDays: 0)
        XCTAssertEqual(moon.fraction, 0, accuracy: 1e-9)
        XCTAssertEqual(moon.illumination, 0, accuracy: 1e-9)
        XCTAssertEqual(moon.name, "ماه نو")
        XCTAssertEqual(moon.age, 0)
    }

    func testFullMoonFourteenPointSevenSixFiveDaysLater() {
        let moon = phase(afterDays: 14.765)
        XCTAssertEqual(moon.fraction, 0.5, accuracy: 0.001)
        XCTAssertEqual(moon.illumination, 1, accuracy: 0.001)
        XCTAssertEqual(moon.name, "ماه کامل")
        XCTAssertEqual(moon.age, 15)
    }

    func testNamesForAllEightPhases() {
        for (index, name) in MoonPhase.names.enumerated() {
            let moon = phase(afterDays: MoonPhase.synodic * Double(index) / 8)
            XCTAssertEqual(moon.name, name)
        }
        XCTAssertEqual(Set(MoonPhase.names).count, 8)
    }

    func testNamesAtKnownDates() {
        XCTAssertEqual(phase(afterDays: 7.4).name, "تربیع اول")
        XCTAssertEqual(phase(afterDays: 22.1).name, "تربیع آخر")
        XCTAssertEqual(phase(afterDays: 3.7).name, "هلال فزاینده")
        XCTAssertEqual(phase(afterDays: 11.1).name, "بدر فزاینده")
        XCTAssertEqual(phase(afterDays: 18.4).name, "بدر کاهنده")
        XCTAssertEqual(phase(afterDays: 25.8).name, "هلال کاهنده")
    }

    func testJustBeforeNextNewMoonWrapsToNewMoon() {
        let moon = phase(afterDays: MoonPhase.synodic - 0.2)
        XCTAssertEqual(moon.name, "ماه نو")
        XCTAssertTrue(moon.fraction > 0.99)
    }

    func testCycleRepeatsEverySynodicMonth() {
        let first = phase(afterDays: 5)
        let second = phase(afterDays: 5 + MoonPhase.synodic * 12)
        XCTAssertEqual(first.fraction, second.fraction, accuracy: 1e-6)
    }

    func testIlluminationRisesThenFalls() {
        XCTAssertTrue(phase(afterDays: 3).illumination < phase(afterDays: 7).illumination)
        XCTAssertTrue(phase(afterDays: 12).illumination < phase(afterDays: 14.7).illumination)
        XCTAssertTrue(phase(afterDays: 18).illumination > phase(afterDays: 25).illumination)
    }

    func testDatesBeforeTheReferenceStillWork() {
        let moon = phase(afterDays: -MoonPhase.synodic / 2)
        XCTAssertEqual(moon.fraction, 0.5, accuracy: 1e-6)
        XCTAssertEqual(moon.name, "ماه کامل")
    }
}
