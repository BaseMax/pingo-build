import AppIntents
import Foundation

struct AlbumEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "آلبوم")
    static let defaultQuery = AlbumQuery()

    let id: String
    let title: String
    let subtitle: String
    let symbol: String

    init(_ item: AlbumItem) {
        id = item.id
        title = EntityCard.title(item.title, fallback: .album)
        subtitle = Persian.number(item.photos.count) + " عکس"
        symbol = LibraryKind.album.symbol
    }

    var displayRepresentation: DisplayRepresentation {
        EntityCard.representation(title: title, subtitle: subtitle, symbol: symbol)
    }
}

struct AlbumQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [AlbumEntity] {
        EntityPicker.pick(identifiers, from: Store.albums.all).map(AlbumEntity.init)
    }

    func suggestedEntities() async throws -> [AlbumEntity] {
        Store.albums.all.map(AlbumEntity.init)
    }

    func defaultResult() async -> AlbumEntity? {
        Store.albums.all.first.map(AlbumEntity.init)
    }
}
