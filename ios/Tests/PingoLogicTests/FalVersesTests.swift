import XCTest
@testable import PingoLogic

final class FalVersesTests: XCTestCase {
    func testHasAtLeastFortyVerses() {
        XCTAssertGreaterThanOrEqual(Fal.verses.count, 40)
    }

    func testEveryVerseHasTwoHemistichsAndHafezAsPoet() {
        for verse in Fal.verses {
            XCTAssertFalse(verse.first.trimmingCharacters(in: .whitespaces).isEmpty)
            XCTAssertFalse(verse.second.trimmingCharacters(in: .whitespaces).isEmpty)
            XCTAssertEqual(verse.poet, "حافظ")
        }
    }

    func testNoDuplicateVerses() {
        XCTAssertEqual(Set(Fal.verses).count, Fal.verses.count)
        XCTAssertEqual(Set(Fal.verses.map(\.first)).count, Fal.verses.count)
        XCTAssertEqual(Set(Fal.verses.map(\.second)).count, Fal.verses.count)
    }

    func testTextUsesPersianLettersAndNoDashes() {
        let forbidden = CharacterSet(charactersIn: "\u{064A}\u{0643}\u{2013}\u{2014}-0123456789")
        for verse in Fal.verses {
            for text in [verse.first, verse.second] {
                XCTAssertNil(text.rangeOfCharacter(from: forbidden), text)
                XCTAssertEqual(text, text.trimmingCharacters(in: .whitespaces))
                XCTAssertFalse(text.contains("  "))
            }
        }
    }
}
