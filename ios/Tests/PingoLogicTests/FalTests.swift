import XCTest
@testable import PingoLogic

final class FalTests: XCTestCase {
    private let start = Persian.calendar.startOfDay(for: Date(timeIntervalSince1970: 1_750_000_000))

    private func day(_ offset: Int, hour: Int = 0) -> Date {
        Persian.shift(start, days: offset).addingTimeInterval(Double(hour) * 3600)
    }

    func testSameDayAndSeedGiveSameVerse() {
        XCTAssertEqual(Fal.verse(on: day(0, hour: 1), seed: 3), Fal.verse(on: day(0, hour: 22), seed: 3))
        XCTAssertEqual(Fal.verse(on: day(5), seed: 0), Fal.verse(on: day(5), seed: 0))
    }

    func testConsecutiveDaysDiffer() {
        for offset in 0..<300 {
            XCTAssertNotEqual(Fal.verse(on: day(offset), seed: 0), Fal.verse(on: day(offset + 1), seed: 0), "day \(offset)")
        }
    }

    func testEverySeedBumpChangesTheVerse() {
        for offset in 0..<60 {
            for seed in 0..<5 {
                XCTAssertNotEqual(Fal.verse(on: day(offset), seed: seed), Fal.verse(on: day(offset), seed: seed + 1), "day \(offset) seed \(seed)")
            }
        }
    }

    func testSeedBumpIsNotJustTomorrowsVerse() {
        let differing = (0..<60).filter { Fal.verse(on: day($0), seed: 1) != Fal.verse(on: day($0 + 1), seed: 0) }
        XCTAssertGreaterThan(differing.count, 50)
    }

    func testAllVersesAppearOverTime() {
        let seen = Set((0..<Fal.verses.count).map { Fal.verse(on: day($0), seed: 0) })
        XCTAssertEqual(seen.count, Fal.verses.count)
    }

    func testNegativeSeedsAndOldDatesAreValid() {
        let old = Date(timeIntervalSince1970: 0)
        XCTAssertTrue(Fal.verses.contains(Fal.verse(on: old, seed: -7)))
        XCTAssertTrue(Fal.verses.contains(Fal.verse(on: day(-4000), seed: Int.min + 1)))
        XCTAssertTrue(Fal.verses.contains(Fal.verse(on: day(4000), seed: Int.max)))
    }
}
