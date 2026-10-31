import Foundation

enum AppVersion {
    static var short: String { value(for: "CFBundleShortVersionString") }
    static var build: String { value(for: "CFBundleVersion") }

    static var display: String {
        "نسخه \(localized(short)) (\(localized(build)))"
    }

    static func localized(_ raw: String) -> String {
        raw.map { character in
            Int(String(character)).map(Persian.number) ?? String(character)
        }.joined()
    }

    private static func value(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "۱"
    }
}
