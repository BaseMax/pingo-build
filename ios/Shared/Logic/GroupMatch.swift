import Foundation

enum GroupMatch {
    static func resolve(declared: String, granted: [String]) -> String {
        pick(declared: declared, granted: granted) ?? granted.first ?? declared
    }

    static func pick(declared: String, granted: [String]) -> String? {
        let rules: [(String) -> Bool] = [
            { $0 == declared },
            { $0.hasPrefix(declared) },
            { $0.hasSuffix(declared) }
        ]
        for rule in rules {
            if let match = granted.first(where: rule) { return match }
        }
        return nil
    }
}
