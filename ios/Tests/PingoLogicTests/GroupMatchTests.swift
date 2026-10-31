import XCTest
@testable import PingoLogic

final class GroupMatchTests: XCTestCase {
    private let base = "group.ir.dsto.pingo"

    func testExactMatchWins() {
        let granted = ["group.other", base + ".ABCDE12345", base]
        XCTAssertEqual(GroupMatch.resolve(declared: base, granted: granted), base)
    }

    func testTeamSuffixAddedBySideloadToolMatches() {
        XCTAssertEqual(GroupMatch.resolve(declared: base, granted: ["group.other", base + ".ABCDE12345"]), base + ".ABCDE12345")
    }

    func testTeamPrefixMatches() {
        XCTAssertEqual(GroupMatch.resolve(declared: base, granted: ["ABCDE12345." + base]), "ABCDE12345." + base)
    }

    func testPrefixIsPreferredOverSuffix() {
        let granted = ["X." + base, base + ".Y"]
        XCTAssertEqual(GroupMatch.resolve(declared: base, granted: granted), base + ".Y")
    }

    func testFallsBackToFirstGrantedWhenNothingMatches() {
        XCTAssertEqual(GroupMatch.resolve(declared: base, granted: ["group.one", "group.two"]), "group.one")
        XCTAssertNil(GroupMatch.pick(declared: base, granted: ["group.one"]))
    }

    func testFallsBackToDeclaredWhenNothingIsGranted() {
        XCTAssertEqual(GroupMatch.resolve(declared: base, granted: []), base)
        XCTAssertNil(GroupMatch.pick(declared: base, granted: []))
    }

    func testUnrelatedLongerNameDoesNotMatchByAccident() {
        XCTAssertNil(GroupMatch.pick(declared: base, granted: ["group.ir.dsto.ping"]))
    }
}
