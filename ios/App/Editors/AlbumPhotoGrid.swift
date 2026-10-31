import SwiftUI

struct AlbumPhotoGrid: View {
    let photos: [String]
    let onRemove: (String) -> Void
    let onMove: (String, String) -> Void
    @State private var targeted: String?

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(photos, id: \.self) { name in
                tile(name)
            }
        }
    }

    private func tile(_ name: String) -> some View {
        AlbumTile(name: name, isTargeted: targeted == name) {
            onRemove(name)
        }
        .draggable(name)
        .dropDestination(for: String.self) { dropped, _ in
            guard let source = dropped.first else { return false }
            onMove(source, name)
            return true
        } isTargeted: { inside in
            if inside {
                targeted = name
            } else if targeted == name {
                targeted = nil
            }
        }
        .transition(.blurFade)
    }
}
