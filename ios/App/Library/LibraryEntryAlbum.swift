import Foundation

extension AlbumItem: LibraryEntry {
    var entryTitle: String { title.entryName }
    var entryTheme: Theme? { theme }

    var entrySubtitle: String {
        photos.isEmpty ? "هنوز عکسی نداره" : Persian.number(photos.count) + " عکس"
    }

    func duplicatedInBackground() async -> AlbumItem {
        var copy = self
        copy.id = UUID().uuidString
        copy.title = title.asCopyName
        let names = photos
        copy.photos = await Task.detached(priority: .userInitiated) {
            names.compactMap(PhotoStore.copy)
        }.value
        return copy
    }

    func cleanUp() {
        photos.forEach { PhotoStore.remove($0) }
    }
}
