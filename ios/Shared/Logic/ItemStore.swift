import Foundation

enum JSONCoding {
    static func encoder(pretty: Bool = false) -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if pretty { encoder.outputFormatting = [.prettyPrinted, .sortedKeys] }
        return encoder
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct ItemStore<Item: Codable & Identifiable & Hashable> where Item.ID == String {
    let key: String
    let kind: PingoKind?

    init(key: String, kind: PingoKind?) {
        self.key = key
        self.kind = kind
    }

    var all: [Item] {
        guard let data = Store.backend.data(for: key) else { return [] }
        return (try? JSONCoding.decoder().decode([Item].self, from: data)) ?? []
    }

    func item(_ id: String) -> Item? {
        all.first { $0.id == id }
    }

    func resolve(_ selection: WidgetSelection) -> Item? {
        let items = all
        return items.first { $0.id == selection.itemID } ?? items.first
    }

    func save(_ items: [Item]) {
        write(items)
        Store.touch(kind)
    }

    func write(_ items: [Item]) {
        guard let data = try? JSONCoding.encoder().encode(items) else { return }
        Store.backend.set(data, for: key)
    }

    func add(_ item: Item) {
        save(all + [item])
    }

    func update(_ id: String, _ body: (inout Item) -> Void) {
        var items = all
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        body(&items[index])
        save(items)
    }

    func remove(_ id: String) {
        let items = all
        let kept = items.filter { $0.id != id }
        guard kept.count != items.count else { return }
        save(kept)
    }

    func move(from source: IndexSet, to destination: Int) {
        let items = all
        let moving = source.filter { items.indices.contains($0) }
        guard !moving.isEmpty else { return }
        let rest = items.enumerated().filter { !moving.contains($0.offset) }.map(\.element)
        let passed = moving.filter { $0 < destination }.count
        let insertion = min(max(destination - passed, 0), rest.count)
        let reordered = Array(rest[..<insertion]) + moving.map { items[$0] } + Array(rest[insertion...])
        save(reordered)
    }
}
