import XCTest
@testable import PingoLogic

final class ExpiryTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_750_000_000)
    private let day: TimeInterval = 86400

    private func status(_ remaining: TimeInterval) -> ExpiryStatus {
        Expiry.status(expiry: now.addingTimeInterval(remaining), now: now)
    }

    func testUnknownWithoutExpiry() {
        let result = Expiry.status(expiry: nil, now: now)
        XCTAssertEqual(result.level, .unknown)
        XCTAssertEqual(result.daysLeft, 0)
        XCTAssertEqual(result.fractionLeft, 0)
        XCTAssertFalse(result.message.isEmpty)
    }

    func testExpiredAtOrBeforeNow() {
        for remaining in [0, -1, -day, -30 * day] {
            let result = status(remaining)
            XCTAssertEqual(result.level, .expired)
            XCTAssertEqual(result.daysLeft, 0)
            XCTAssertEqual(result.fractionLeft, 0)
        }
    }

    func testExpiredMessageTellsToReinstallAndKeepsData() {
        let message = status(-60).message
        XCTAssertTrue(message.contains("Sideloadly"))
        XCTAssertTrue(message.contains("Impactor"))
        XCTAssertTrue(message.contains("اطلاعاتت می‌مونه"))
    }

    func testNoCopyMentionsXcodeOrRun() {
        let copies = [status(-60).message, status(day).message, status(5 * day).message, Expiry.status(expiry: nil, now: now).message,
                      ExpiryCopy.reminderBody, ExpiryCopy.renewalRule, ExpiryCopy.reminderHint]
        for copy in copies {
            XCTAssertFalse(copy.contains("Xcode"), copy)
            XCTAssertFalse(copy.contains("Run"), copy)
        }
    }

    func testReminderHintNamesBothNotifications() {
        let hint = ExpiryCopy.reminderHint
        XCTAssertTrue(hint.contains("دو اعلان"))
        XCTAssertTrue(hint.contains("۲۴"))
        XCTAssertTrue(hint.contains("۳"))
        XCTAssertEqual(Expiry.reminderLeads, [86400, 10800] as [TimeInterval])
    }

    func testSoonWhenTwoDaysOrLess() {
        XCTAssertEqual(status(2 * day).level, .soon)
        XCTAssertEqual(status(2 * day).daysLeft, 2)
        XCTAssertEqual(status(day + 1).level, .soon)
        XCTAssertEqual(status(60).level, .soon)
        XCTAssertEqual(status(60).daysLeft, 1)
    }

    func testHealthyWhenMoreThanTwoDays() {
        XCTAssertEqual(status(2 * day + 1).level, .healthy)
        XCTAssertEqual(status(2 * day + 1).daysLeft, 3)
        XCTAssertEqual(status(5 * day).level, .healthy)
        XCTAssertEqual(status(5 * day).daysLeft, 5)
    }

    func testDaysLeftRoundsUp() {
        XCTAssertEqual(status(4 * day - 1).daysLeft, 4)
        XCTAssertEqual(status(4 * day + 1).daysLeft, 5)
        XCTAssertEqual(status(0.5 * day).daysLeft, 1)
    }

    func testFractionLeftIsClampedAgainstLifetime() {
        XCTAssertEqual(Expiry.lifetimeDays, 7)
        XCTAssertEqual(status(7 * day).fractionLeft, 1, accuracy: 1e-9)
        XCTAssertEqual(status(3.5 * day).fractionLeft, 0.5, accuracy: 1e-9)
        XCTAssertEqual(status(30 * day).fractionLeft, 1, accuracy: 1e-9)
        XCTAssertEqual(status(day).fractionLeft, 1.0 / 7, accuracy: 1e-9)
    }

    func testMessagesUsePersianDigitsAndNoDashes() {
        for remaining in [day / 2, 2 * day, 5 * day] {
            let message = status(remaining).message
            XCTAssertNil(message.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789-\u{2013}\u{2014}")), message)
        }
        XCTAssertTrue(status(5 * day).message.contains("۵"))
        XCTAssertTrue(status(2 * day).message.contains("۲"))
        XCTAssertTrue(status(day / 2).message.contains("یک روز"))
    }

    func testMessagesDifferByLevel() {
        let messages = [status(-1), status(day), status(5 * day), Expiry.status(expiry: nil, now: now)].map(\.message)
        XCTAssertEqual(Set(messages).count, 4)
    }

    func testReminderDatesBeforeExpiry() {
        let expiry = now.addingTimeInterval(5 * day)
        let dates = Expiry.reminderDates(expiry: expiry, now: now)
        XCTAssertEqual(dates, [expiry.addingTimeInterval(-24 * 3600), expiry.addingTimeInterval(-3 * 3600)])
    }

    func testReminderDatesKeepOnlyTheFuture() {
        let expiry = now.addingTimeInterval(10 * 3600)
        XCTAssertEqual(Expiry.reminderDates(expiry: expiry, now: now), [expiry.addingTimeInterval(-3 * 3600)])
        let close = now.addingTimeInterval(2 * 3600)
        XCTAssertEqual(Expiry.reminderDates(expiry: close, now: now), [])
        XCTAssertEqual(Expiry.reminderDates(expiry: now.addingTimeInterval(-day), now: now), [])
    }

    func testReminderDatesAreAscending() {
        let dates = Expiry.reminderDates(expiry: now.addingTimeInterval(3 * day), now: now)
        XCTAssertEqual(dates, dates.sorted())
        XCTAssertEqual(dates.count, 2)
    }
}

final class ProvisioningProfileTests: XCTestCase {
    private let expiration = Date(timeIntervalSince1970: 1_760_000_000)

    private func blob(_ plist: [String: Any]) throws -> Data {
        let xml = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let head = Data((0..<300).map { UInt8(($0 * 7 + 3) % 200 + 40) })
        let tail = Data((0..<200).map { UInt8(($0 * 13 + 5) % 200 + 40) })
        return head + xml + tail
    }

    private var full: [String: Any] {
        [
            "Name": "iOS Team Provisioning Profile: ir.dsto.pingo",
            "TeamIdentifier": ["ABCDE12345", "ZZZZZ99999"],
            "ExpirationDate": expiration,
            "Entitlements": ["com.apple.security.application-groups": ["group.ir.dsto.pingo", "group.other"]],
        ]
    }

    func testParsesAllFields() throws {
        let profile = try XCTUnwrap(ProvisioningProfile.parse(try blob(full)))
        XCTAssertEqual(profile.name, "iOS Team Provisioning Profile: ir.dsto.pingo")
        XCTAssertEqual(profile.teamID, "ABCDE12345")
        XCTAssertEqual(profile.expirationDate, expiration)
        XCTAssertEqual(profile.groups, ["group.ir.dsto.pingo", "group.other"])
    }

    func testMissingFieldsBecomeNilOrEmpty() throws {
        let profile = try XCTUnwrap(ProvisioningProfile.parse(try blob(["Name": "Only name"])))
        XCTAssertEqual(profile.name, "Only name")
        XCTAssertNil(profile.teamID)
        XCTAssertNil(profile.expirationDate)
        XCTAssertEqual(profile.groups, [])
    }

    func testEntitlementsWithoutGroupsGiveEmptyGroups() throws {
        var plist = full
        plist["Entitlements"] = ["application-identifier": "ABCDE12345.ir.dsto.pingo"]
        XCTAssertEqual(try XCTUnwrap(ProvisioningProfile.parse(try blob(plist))).groups, [])
    }

    func testPlainPlistWithoutWrapperAlsoParses() throws {
        let xml = try PropertyListSerialization.data(fromPropertyList: full, format: .xml, options: 0)
        XCTAssertEqual(ProvisioningProfile.parse(xml)?.teamID, "ABCDE12345")
    }

    func testReturnsNilWithoutPlist() {
        XCTAssertNil(ProvisioningProfile.parse(Data()))
        XCTAssertNil(ProvisioningProfile.parse(Data((0..<500).map { UInt8($0 % 100 + 40) })))
        XCTAssertNil(ProvisioningProfile.parse(Data("<?xml but never closed".utf8)))
        XCTAssertNil(ProvisioningProfile.parse(Data("</plist> before <?xml".utf8)))
    }

    func testReturnsNilForBrokenPlist() {
        XCTAssertNil(ProvisioningProfile.parse(Data("junk <?xml version=\"1.0\"?><plist><dict><key>".utf8) + Data("</plist> tail".utf8)))
    }

    func testEmbeddedWithoutProfileIsNil() {
        XCTAssertNil(ProvisioningProfile.embedded(in: Bundle(for: ProvisioningProfileTests.self)))
    }

    func testEmbeddedReadsProfileFromBundleDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try blob(full).write(to: directory.appendingPathComponent("embedded.mobileprovision"))
        let bundle = try XCTUnwrap(Bundle(path: directory.path))
        XCTAssertEqual(ProvisioningProfile.embedded(in: bundle)?.teamID, "ABCDE12345")
    }
}
