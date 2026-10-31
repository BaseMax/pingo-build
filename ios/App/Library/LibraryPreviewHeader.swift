import SwiftUI

struct LibraryPreviewHeader: View {
    let kind: LibraryKind
    let id: String
    var size: CardSize = .medium

    var body: some View {
        FacePreview(kind: kind.widget, size: size, selection: WidgetSelection(itemID: id))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }
}
