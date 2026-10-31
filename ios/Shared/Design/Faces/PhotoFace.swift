import SwiftUI
import WidgetKit

struct PhotoFace: View {
    let album: AlbumItem?
    let date: Date
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: .ink, mode: mode) }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder private var content: some View {
        if let album, let image = PhotoPick.image(for: album, at: date, size: size) {
            PhotoCover(image: image, title: caption(for: album), size: size)
        } else {
            FaceEmpty(symbol: "photo.fill", title: "آلبوم خالیه", palette: palette)
        }
    }

    private func caption(for album: AlbumItem) -> String? {
        guard album.showsTitle, !album.title.isEmpty else { return nil }
        return album.title
    }
}
