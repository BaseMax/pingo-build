import UIKit

enum PhotoPick {
    static func index(for album: AlbumItem, at date: Date) -> Int? {
        guard !album.photos.isEmpty else { return nil }
        let step = Double(max(album.minutes, 1) * 60)
        let slot = Int((date.timeIntervalSince1970 / step).rounded(.down))
        let count = album.photos.count
        return ((slot % count) + count) % count
    }

    static func maxSide(for size: CardSize) -> CGFloat {
        max(size.points.width, size.points.height) * 3
    }

    static func image(for album: AlbumItem, at date: Date, size: CardSize) -> UIImage? {
        guard let start = index(for: album, at: date) else { return nil }
        let count = album.photos.count
        for offset in 0..<count {
            let name = album.photos[(start + offset) % count]
            if let image = PhotoStore.image(named: name, maxSide: maxSide(for: size)) { return image }
        }
        return nil
    }
}
