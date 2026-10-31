import SwiftUI
import UIKit

struct AlbumTile: View {
    let name: String
    let isTargeted: Bool
    let onRemove: () -> Void
    @State private var image: UIImage?

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay { content }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .topTrailing) {
                removeButton.padding(6)
            }
            .scaleEffect(isTargeted ? 1.06 : 1)
            .animation(.liquid, value: isTargeted)
            .task(id: name) { await load() }
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .transition(.blurFade)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Color.primary.opacity(0.06)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
    }

    private var removeButton: some View {
        Button(action: onRemove) {
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.primary)
                .frame(width: 28, height: 28)
                .glassCircle(interactive: true)
        }
        .glassButtonStyle()
        .accessibilityLabel("حذف عکس")
    }

    private func load() async {
        let side: CGFloat = 320
        let loaded = await Task.detached(priority: .userInitiated) {
            PhotoStore.thumbnail(named: name, side: side)
        }.value
        withAnimation(.liquidSoft) {
            image = loaded
        }
    }
}
