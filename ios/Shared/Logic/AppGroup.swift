import Foundation

enum AppGroup {
    static let defaultIdentifier = "group.ir.dsto.pingo"

    static let declared: String = Bundle.main.object(forInfoDictionaryKey: "PingoGroup") as? String ?? defaultIdentifier

    static let identifier: String = GroupMatch.resolve(
        declared: declared,
        granted: ProvisioningProfile.embedded(in: .main)?.groups ?? []
    )

    static let isShared: Bool = sharedContainer != nil

    static let isExtension: Bool = isExtensionBundle(Bundle.main.bundleURL)

    static let isUnreachableFromWidget: Bool = isExtension && !isShared

    static let defaults: UserDefaults = isShared ? (UserDefaults(suiteName: identifier) ?? .standard) : .standard

    static var container: URL {
        sharedContainer ?? localContainer
    }

    static func isExtensionBundle(_ url: URL) -> Bool {
        url.pathExtension == "appex"
    }

    private static let sharedContainer: URL? = {
        #if canImport(Darwin)
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
        #else
        nil
        #endif
    }()

    private static let localContainer: URL = {
        let fallback = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fallback
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }()
}
