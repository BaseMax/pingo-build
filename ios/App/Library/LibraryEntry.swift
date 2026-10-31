import Foundation

protocol LibraryEntry: Codable, Hashable, Identifiable where ID == String {
    var id: String { get set }
    var entryTitle: String { get }
    var entrySubtitle: String { get }
    var entrySymbol: String? { get }
    var entryTheme: Theme? { get }
    mutating func markAsCopy()
    func cleanUp()
}

extension LibraryEntry {
    var entrySymbol: String? { nil }

    mutating func markAsCopy() {}

    func cleanUp() {}

    func duplicated() -> Self {
        var copy = self
        copy.id = UUID().uuidString
        copy.markAsCopy()
        return copy
    }
}

extension String {
    var entryFirstLine: String? {
        for line in split(whereSeparator: \.isNewline) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return String(trimmed.prefix(60))
            }
        }
        return nil
    }

    var entryName: String {
        entryFirstLine ?? "بدون عنوان"
    }

    var asCopyName: String {
        entryFirstLine.map { $0 + " کپی" } ?? self
    }
}
