import SwiftUI

private struct CardIdentity: Hashable {
    let generation: Int
    let isLive: Bool
}

struct FacePreview: View {
    private let kind: PingoKind
    private let size: CardSize
    private let selection: WidgetSelection

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.animates) private var isVisible
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var generation = 0
    @State private var stamp = Date.now
    @State private var render = PreviewRender()

    init(kind: PingoKind, size: CardSize, selection: WidgetSelection = WidgetSelection()) {
        self.kind = kind
        self.size = size
        self.selection = selection
    }

    private var isLive: Bool { isVisible && !reduceMotion }

    var body: some View {
        ZStack {
            card
                .id(CardIdentity(generation: generation, isLive: isLive))
                .transition(.blurFade)
        }
        .frame(width: size.points.width, height: size.points.height)
        .refreshesOnStoreChange($stamp)
        .ticksEveryMinute(kind == .clock, stamp: $stamp)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { renew() }
        }
    }

    private var card: some View {
        let layers = render.layers(for: PreviewKey(kind: kind, size: size, selection: selection, stamp: stamp))
        return layers.face
            .environment(\.animates, isLive)
            .environment(\.layoutDirection, .rightToLeft)
            .frame(width: size.points.width, height: size.points.height)
            .background { layers.background }
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCorner, style: .continuous))
            .shadow(color: Color.black.opacity(0.14), radius: 22, y: 12)
    }

    private func renew() {
        guard isVisible else { return }
        stamp = .now
        withAnimation(.liquidSoft) { generation += 1 }
    }
}
