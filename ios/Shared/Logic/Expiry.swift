import Foundation

struct ProvisioningProfile: Equatable {
    let name: String?
    let teamID: String?
    let expirationDate: Date?
    let groups: [String]

    static func parse(_ data: Data) -> ProvisioningProfile? {
        guard let plist = embeddedPlist(in: data),
              let values = try? PropertyListSerialization.propertyList(from: plist, options: [], format: nil) as? [String: Any] else { return nil }
        let entitlements = values["Entitlements"] as? [String: Any]
        return ProvisioningProfile(
            name: values["Name"] as? String,
            teamID: (values["TeamIdentifier"] as? [String])?.first,
            expirationDate: values["ExpirationDate"] as? Date,
            groups: entitlements?["com.apple.security.application-groups"] as? [String] ?? []
        )
    }

    static func embedded(in bundle: Bundle) -> ProvisioningProfile? {
        guard let url = bundle.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url) else { return nil }
        return parse(data)
    }

    private static func embeddedPlist(in data: Data) -> Data? {
        guard let start = data.range(of: Data("<?xml".utf8)),
              let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex) else { return nil }
        return data.subdata(in: start.lowerBound..<end.upperBound)
    }
}

enum ExpiryLevel: Equatable {
    case unknown, healthy, soon, expired
}

struct ExpiryStatus: Equatable {
    let level: ExpiryLevel
    let daysLeft: Int
    let fractionLeft: Double
    let message: String
}

enum Expiry {
    static let lifetimeDays = 7
    static let soonDays = 2
    static let reminderLeads: [TimeInterval] = [24 * 3600, 3 * 3600]

    static func status(expiry: Date?, now: Date) -> ExpiryStatus {
        guard let expiry else {
            return ExpiryStatus(level: .unknown, daysLeft: 0, fractionLeft: 0, message: "زمان اعتبار نصب پینگو مشخص نیست. اگه از Xcode نصبش کردی، هر چند روز یه بار دوباره Run بزن.")
        }
        guard expiry > now else {
            return ExpiryStatus(level: .expired, daysLeft: 0, fractionLeft: 0, message: "اعتبار نصب تموم شده. گوشی رو به کامپیوتر وصل کن و توی Xcode دکمه Run رو بزن تا دوباره زنده بشه.")
        }
        let remaining = expiry.timeIntervalSince(now)
        let days = max(Int((remaining / 86400).rounded(.up)), 0)
        let level: ExpiryLevel = days <= soonDays ? .soon : .healthy
        return ExpiryStatus(
            level: level,
            daysLeft: days,
            fractionLeft: min(max(remaining / (Double(lifetimeDays) * 86400), 0), 1),
            message: message(level: level, days: days)
        )
    }

    static func reminderDates(expiry: Date, now: Date) -> [Date] {
        reminderLeads.map { expiry.addingTimeInterval(-$0) }.filter { $0 > now }.sorted()
    }

    private static func message(level: ExpiryLevel, days: Int) -> String {
        let span = days == 1 ? "یک روز" : Persian.number(days) + " روز"
        switch level {
        case .soon: return "فقط \(span) دیگه مونده. زودتر گوشی رو وصل کن و توی Xcode دکمه Run رو بزن."
        default: return "نصب پینگو تا \(span) دیگه اعتبار داره. همه‌چیز آماده‌ست."
        }
    }
}
