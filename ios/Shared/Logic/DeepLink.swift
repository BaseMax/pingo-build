import Foundation

struct ItemRoute: Hashable {
    let kind: LibraryKind
    let id: String
}

enum Route: Hashable {
    case kind(PingoKind)
    case item(ItemRoute)
    case library(LibraryKind?)
    case settings
    case guide(PingoKind?)

    static let scheme = "pingo"

    private static let home = URL(string: "pingo://settings")!

    init?(url: URL) {
        guard url.scheme == Self.scheme,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host,
              let parts = Self.segments(components.percentEncodedPath),
              let route = Self.route(host: host, parts: parts) else { return nil }
        self = route
    }

    var url: URL {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = host
        components.percentEncodedPath = path
        return components.url ?? Self.home
    }

    private var host: String {
        switch self {
        case .kind: "kind"
        case .item: "item"
        case .library: "library"
        case .settings: "settings"
        case .guide: "guide"
        }
    }

    private var path: String {
        switch self {
        case .kind(let kind): "/" + kind.rawValue
        case .item(let route): "/" + route.kind.rawValue + "/" + Self.escape(route.id)
        case .library(let kind): kind.map { "/" + $0.rawValue } ?? ""
        case .settings: ""
        case .guide(let kind): kind.map { "/" + $0.rawValue } ?? ""
        }
    }

    private static func escape(_ id: String) -> String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove("/")
        return id.addingPercentEncoding(withAllowedCharacters: allowed) ?? id
    }

    private static func segments(_ encodedPath: String) -> [String]? {
        guard !encodedPath.isEmpty else { return [] }
        guard encodedPath.hasPrefix("/") else { return nil }
        let parts = encodedPath.dropFirst().split(separator: "/", omittingEmptySubsequences: false)
        let decoded = parts.compactMap { $0.removingPercentEncoding }
        return decoded.count == parts.count ? decoded : nil
    }

    private static func route(host: String, parts: [String]) -> Route? {
        switch (host, parts.count) {
        case ("kind", 1): PingoKind(rawValue: parts[0]).map { .kind($0) }
        case ("item", 2): item(kind: parts[0], id: parts[1])
        case ("library", 0): .library(nil)
        case ("library", 1): LibraryKind(rawValue: parts[0]).map { .library($0) }
        case ("settings", 0): .settings
        case ("guide", 0): .guide(nil)
        case ("guide", 1): PingoKind(rawValue: parts[0]).map { .guide($0) }
        default: nil
        }
    }

    private static func item(kind: String, id: String) -> Route? {
        guard let kind = LibraryKind(rawValue: kind), !id.isEmpty else { return nil }
        return .item(ItemRoute(kind: kind, id: id))
    }
}
