import Foundation

enum DataWiper {
    static func wipeAll() async {
        await Task.detached(priority: .userInitiated) { wipeSync() }.value
    }

    private static func wipeSync() {
        Store.notes.save([])
        Store.countdowns.save([])
        Store.habits.save([])
        Store.todos.save([])
        Store.counters.save([])
        Store.albums.save([])
        var settings = Store.settings
        settings.seeded = true
        Store.settings = settings
        PhotoSweeper.sweep()
    }
}
