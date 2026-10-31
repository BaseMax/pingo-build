import Foundation

enum DataWiper {
    static func wipeAll() {
        Store.albums.all.flatMap(\.photos).forEach { PhotoStore.remove($0) }
        Store.notes.save([])
        Store.countdowns.save([])
        Store.habits.save([])
        Store.todos.save([])
        Store.counters.save([])
        Store.albums.save([])
        var settings = Store.settings
        settings.seeded = true
        Store.settings = settings
    }
}
