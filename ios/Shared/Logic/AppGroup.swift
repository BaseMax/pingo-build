import Foundation

enum AppGroup {
    static let identifier: String = ProvisioningProfile.embedded(in: .main)?.groups.first
        ?? Bundle.main.object(forInfoDictionaryKey: "PingoGroup") as? String
        ?? "group.ir.dsto.pingo"

    static let defaults: UserDefaults = UserDefaults(suiteName: identifier) ?? .standard

    static var container: URL {
        sharedContainer ?? FileManager.default.temporaryDirectory
    }

    private static var sharedContainer: URL? {
        #if canImport(Darwin)
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
        #else
        nil
        #endif
    }
}
