import SwiftUI

extension PingoKind {
    var galleryPreviewSize: CardSize {
        sizes.first ?? .small
    }

    var galleryIsWide: Bool {
        galleryPreviewSize != .small
    }
}

struct KindCard: View {
    let kind: PingoKind
    let namespace: Namespace.ID

    var body: some View {
        NavigationLink(value: kind) {
            VStack(spacing: 10) {
                preview
                labels
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(Pressable())
        .pingRipple()
        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
        .accessibilityLabel(kind.title)
        .accessibilityHint(kind.about)
    }

    private var preview: some View {
        ScaledPreview(kind: kind, size: kind.galleryPreviewSize)
            .matchedTransitionSource(id: kind, in: namespace)
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(kind.title)
                .dasto(16)
                .foregroundStyle(Color.primary)
            Text(kind.about)
                .dasto(12)
                .foregroundStyle(Color.secondary)
                .lineLimit(2, reservesSpace: true)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}

private struct ScaledPreview: View {
    let kind: PingoKind
    let size: CardSize

    private var ratio: CGFloat {
        size.points.width / size.points.height
    }

    var body: some View {
        GeometryReader { proxy in
            FacePreview(kind: kind, size: size)
                .allowsHitTesting(false)
                .scaleEffect(proxy.size.width / size.points.width)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(ratio, contentMode: .fit)
    }
}
