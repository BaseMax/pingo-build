import Foundation

extension TodoList {
    var doneCount: Int {
        items.filter(\.done).count
    }

    var remaining: Int {
        items.count - doneCount
    }

    mutating func toggle(_ itemID: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].done.toggle()
    }

    mutating func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(TodoEntry(text: trimmed))
    }

    mutating func clearDone() {
        items.removeAll { $0.done }
    }
}
