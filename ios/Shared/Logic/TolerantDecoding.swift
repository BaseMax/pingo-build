import Foundation

struct DecodedCollection<Item> {
    let items: [Item]
    let isComplete: Bool
}

enum TolerantDecoding {
    static func decode<Item: Decodable>(_ type: Item.Type, from data: Data) -> DecodedCollection<Item> {
        if let all = try? JSONCoding.decoder().decode([Item].self, from: data) {
            return DecodedCollection(items: all, isComplete: true)
        }
        guard let elements = try? JSONSerialization.jsonObject(with: data) as? [Any] else {
            return DecodedCollection(items: [], isComplete: false)
        }
        let items = elements.compactMap { element in decodeOne(Item.self, from: element) }
        return DecodedCollection(items: items, isComplete: items.count == elements.count)
    }

    private static func decodeOne<Item: Decodable>(_ type: Item.Type, from element: Any) -> Item? {
        guard JSONSerialization.isValidJSONObject(element),
              let data = try? JSONSerialization.data(withJSONObject: element) else { return nil }
        return try? JSONCoding.decoder().decode(Item.self, from: data)
    }
}
