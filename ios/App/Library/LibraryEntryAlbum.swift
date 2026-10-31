import Foundation

extension AlbumItem: LibraryEntry {
    var entryTitle: String { title.entryName }
    var entryTheme: Theme? { theme }

    var entrySubtitle: String {
        photos.isEmpty ? "هنوز عکسی نداره" : Persian.number(photos.count) + " عکس"
    }

    mutating func markAsCopy() {
        title = title.asCopyName
        photos = photos.compactMap { name in
            PhotoStore.data(named: name).flatMap { PhotoStore.save($0) }
        }
    }

    func cleanUp() {
        photos.forEach { PhotoStore.remove($0) }
    }
}
