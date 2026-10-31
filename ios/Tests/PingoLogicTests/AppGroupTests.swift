import XCTest
@testable import PingoLogic

final class AppGroupTests: XCTestCase {
    func testIdentifierFallsBackToDefaultGroup() {
        XCTAssertEqual(AppGroup.identifier, "group.ir.dsto.pingo")
        XCTAssertEqual(AppGroup.declared, AppGroup.defaultIdentifier)
    }

    func testContainerIsAFileURLAndNeverTheTemporaryDirectory() {
        XCTAssertTrue(AppGroup.container.isFileURL)
        XCTAssertFalse(AppGroup.container.path.hasPrefix(FileManager.default.temporaryDirectory.path))
    }

    func testUnsharedContainerExistsAndIsWritable() throws {
        let probe = AppGroup.container.appendingPathComponent("pingo-tests-" + UUID().uuidString)
        try Data([1]).write(to: probe)
        defer { try? FileManager.default.removeItem(at: probe) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: probe.path))
    }

    func testWithoutEntitlementsTheGroupIsNotShared() {
        XCTAssertFalse(AppGroup.isShared)
        XCTAssertTrue(AppGroup.defaults === UserDefaults.standard)
    }

    func testDefaultsWriteAndRead() {
        let key = "pingo.tests." + UUID().uuidString
        AppGroup.defaults.set(7, forKey: key)
        defer { AppGroup.defaults.removeObject(forKey: key) }
        XCTAssertEqual(AppGroup.defaults.integer(forKey: key), 7)
    }

    func testExtensionDetectionUsesTheBundleExtension() {
        XCTAssertTrue(AppGroup.isExtensionBundle(URL(fileURLWithPath: "/a/Pingo.app/PlugIns/Widgets.appex")))
        XCTAssertFalse(AppGroup.isExtensionBundle(URL(fileURLWithPath: "/a/Pingo.app")))
        XCTAssertFalse(AppGroup.isExtension)
        XCTAssertFalse(AppGroup.isUnreachableFromWidget)
    }
}
