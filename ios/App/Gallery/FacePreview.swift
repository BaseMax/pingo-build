import SwiftUI

private struct StoreStamp: ViewModifier {
    @Binding var stamp: Date

    func body(content: Content) -> some View {
        content.onReceive(NotificationCenter.default.publisher(for: .pingoStoreChanged)) { _ in
            withAnimation(.liquidSoft) { stamp = .now }
        }
    }
}

private extension View {
    func refreshesOnStoreChange(_ stamp: Binding<Date>) -> some View {
        modifier(StoreStamp(stamp: stamp))
    }
}

struct FacePreview: View {
    private let kind: PingoKind
    private let size: CardSize
    private let selection: WidgetSelection

    @Environment(\.scenePhase) private var scenePhase
    @State private var generation = 0
    @State private var stamp = Date.now

    init(kind: PingoKind, size: CardSize, selection: WidgetSelection = WidgetSelection()) {
        self.kind = kind
        self.size = size
        self.selection = selection
    }

    var body: some View {
        ZStack {
            card
                .id(generation)
                .transition(.blurFade)
        }
        .frame(width: size.points.width, height: size.points.height)
        .refreshesOnStoreChange($stamp)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { renew() }
        }
    }

    private var card: some View {
        kind.face(size: size, date: stamp, selection: selection)
            .environment(\.animates, true)
            .environment(\.layoutDirection, .rightToLeft)
            .frame(width: size.points.width, height: size.points.height)
            .background { kind.background(selection: selection) }
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCorner, style: .continuous))
            .shadow(color: Color.black.opacity(0.14), radius: 22, y: 12)
    }

    private func renew() {
        stamp = .now
        withAnimation(.liquidSoft) { generation += 1 }
    }
}

struct AccessoryPreview: View {
    private let kind: PingoKind
    private let shape: AccessoryShape
    private let selection: WidgetSelection

    @State private var stamp = Date.now

    init(kind: PingoKind, shape: AccessoryShape, selection: WidgetSelection = WidgetSelection()) {
        self.kind = kind
        self.shape = shape
        self.selection = selection
    }

    var body: some View {
        kind.accessoryFace(shape: shape, date: stamp, selection: selection)
            .foregroundStyle(Color.white)
            .tint(Color.white)
            .environment(\.layoutDirection, .rightToLeft)
            .padding(.horizontal, shape == .inline ? 12 : 0)
            .frame(width: plateSize.width, height: plateSize.height)
            .background { plate }
            .clipShape(plateShape)
            .refreshesOnStoreChange($stamp)
    }

    private var plateSize: CGSize {
        switch shape {
        case .circular: CGSize(width: 76, height: 76)
        case .rectangular: CGSize(width: 160, height: 76)
        case .inline: CGSize(width: 220, height: 32)
        }
    }

    private var plateShape: AnyShape {
        switch shape {
        case .circular: AnyShape(Circle())
        case .rectangular: AnyShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        case .inline: AnyShape(Capsule())
        }
    }

    private var plate: some View {
        plateShape
            .fill(Color.black.opacity(0.55))
            .overlay {
                plateShape.stroke(Color.white.opacity(0.14), lineWidth: 0.5)
            }
    }
}
