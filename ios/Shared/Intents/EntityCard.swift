import AppIntents
import Foundation

enum EntityCard {
    static let noteLimit = 30

    static func representation(title: String, subtitle: String, symbol: String) -> DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(subtitle)",
            image: DisplayRepresentation.Image(systemName: symbol)
        )
    }

    static func title(_ text: String, fallback: LibraryKind) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback.title : trimmed
    }

    static func noteTitle(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstLine = (trimmed.components(separatedBy: .newlines).first ?? "").trimmingCharacters(in: .whitespaces)
        guard !firstLine.isEmpty else { return "یادداشت بدون متن" }
        guard firstLine.count > noteLimit else { return firstLine }
        return String(firstLine.prefix(noteLimit)) + "…"
    }
}

enum EntityPicker {
    static func pick<Item: Identifiable>(_ identifiers: [String], from items: [Item]) -> [Item] where Item.ID == String {
        let byID = Dictionary(items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return identifiers.compactMap { byID[$0] }
    }
}
