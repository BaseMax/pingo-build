import PhotosUI
import SwiftUI

enum AlbumImporter {
    static func importPhotos(_ items: [PhotosPickerItem]) async -> [String] {
        var names: [String] = []
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            let name = await Task.detached(priority: .userInitiated) { PhotoStore.save(data) }.value
            if let name {
                names.append(name)
            }
        }
        return names
    }
}
