import XCTest
@testable import PingoLogic

final class AppGroupTests: XCTestCase {
    func testIdentifierFallsBackToDefaultGroup() {
        XCTAssertEqual(AppGroup.identifier, "group.ir.dsto.pingo")
    }

    func testContainerIsAFileURL() {
        XCTAssertTrue(AppGroup.container.isFileURL)
    }

    func testDefaultsWriteAndRead() {
        let key = "pingo.tests." + UUID().uuidString
        AppGroup.defaults.set(7, forKey: key)
        defer { AppGroup.defaults.removeObject(forKey: key) }
        XCTAssertEqual(AppGroup.defaults.integer(forKey: key), 7)
    }
}
