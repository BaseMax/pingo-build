import Foundation

enum BackupError: Error {
    case unsupportedVersion(Int)
}

private struct BackupHeader: Decodable {
    let version: Int
}

struct Backup: Codable {
    static let currentVersion = 1

    var version: Int
    var exportedAt: Date
    var notes: [NoteItem]
    var countdowns: [CountdownItem]
    var habits: [HabitItem]
    var todos: [TodoList]
    var counters: [CounterItem]
    var albums: [AlbumItem]
    var settings: AppSettings
    var photos: [String: Data]

    static func make(photoLoader: (String) -> Data?) -> Backup {
        let albums = Store.albums.all
        let names = Set(albums.flatMap(\.photos))
        let photos = names.reduce(into: [String: Data]()) { result, name in
            result[name] = photoLoader(name)
        }
        return Backup(
            version: currentVersion,
            exportedAt: .now,
            notes: Store.notes.all,
            countdowns: Store.countdowns.all,
            habits: Store.habits.all,
            todos: Store.todos.all,
            counters: Store.counters.all,
            albums: albums,
            settings: Store.settings,
            photos: photos
        )
    }

    func encoded() throws -> Data {
        try JSONCoding.encoder(pretty: true).encode(self)
    }

    static func decoded(from data: Data) throws -> Backup {
        let header = try JSONCoding.decoder().decode(BackupHeader.self, from: data)
        guard header.version <= currentVersion else { throw BackupError.unsupportedVersion(header.version) }
        return try JSONCoding.decoder().decode(Backup.self, from: data)
    }

    func restore(photoSaver: (String, Data) -> Void) {
        photos.forEach { photoSaver($0.key, $0.value) }
        Store.notes.write(notes)
        Store.countdowns.write(countdowns)
        Store.habits.write(habits)
        Store.todos.write(todos)
        Store.counters.write(counters)
        Store.albums.write(albums)
        var restored = settings
        restored.onboarded = restored.onboarded || Store.settings.onboarded
        Store.settings = restored
    }
}
