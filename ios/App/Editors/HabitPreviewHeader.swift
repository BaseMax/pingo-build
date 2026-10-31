import SwiftUI

struct ItemPreviewHeader: View {
    private let kind: PingoKind
    private let id: String
    @State private var size: CardSize

    init(kind: PingoKind, id: String) {
        self.kind = kind
        self.id = id
        let preferred: CardSize = kind.sizes.contains(.medium) ? .medium : (kind.sizes.first ?? .small)
        _size = State(initialValue: preferred)
    }

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                FacePreview(kind: kind, size: size, selection: WidgetSelection(itemID: id))
                    .id(size)
                    .transition(.blurFade)
            }
            .frame(maxWidth: .infinity)
            .frame(height: size.points.height + 12)
            .animation(.liquid, value: size)
            if kind.sizes.count > 1 {
                LiquidSegmented(kind.sizes, selection: $size) { $0.title }
            }
        }
    }
}

extension Theme {
    static func resolved(_ explicit: Theme?, for kind: PingoKind) -> Theme {
        explicit ?? Store.theme(for: kind)
    }

    var panelTint: Color {
        switch self {
        case .sky: Color.ocean
        case .leaf: Color.leaf
        case .ink: Color(hex: 0x636366)
        default: Color.signal
        }
    }
}

extension View {
    func editorStage(_ index: Int) -> some View {
        reveal(Double(index) * 0.06).scrollBlur()
    }
}
