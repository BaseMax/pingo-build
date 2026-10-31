import SwiftUI

struct FloatingAction: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let tint: Color
    let perform: () -> Void
}

struct FloatingAddMenu: View {
    private let actions: [FloatingAction]
    @Binding private var isOpen: Bool
    @Namespace private var space
    @Environment(\.scenePhase) private var scenePhase

    init(actions: [FloatingAction], isOpen: Binding<Bool>) {
        self.actions = actions
        _isOpen = isOpen
    }

    var body: some View {
        menu
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .animation(.liquid, value: isOpen)
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { close() }
            }
    }

    private var menu: some View {
        GlassGroup(spacing: 8) {
            VStack(alignment: .trailing, spacing: 12) {
                if isOpen {
                    ForEach(Array(actions.enumerated()), id: \.element.id) { pair in
                        pill(pair.element, delay: Double(actions.count - 1 - pair.offset) * 0.05)
                    }
                }
                addButton
            }
        }
        .padding(.trailing, Layout.gutter)
        .padding(.bottom, Layout.dockClearance)
    }

    private var addButton: some View {
        Button(action: toggle) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(isOpen ? 45 : 0))
                .frame(width: 58, height: 58)
                .glassCircle(tint: Color.signal, interactive: true)
                .glassID("add", in: space)
        }
        .glassButtonStyle()
        .accessibilityLabel(isOpen ? "بستن" : "افزودن")
    }

    private func pill(_ action: FloatingAction, delay: Double) -> some View {
        Button {
            choose(action)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: action.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(action.tint, in: Circle())
                Text(action.title)
                    .dasto(15)
                    .foregroundStyle(Color.primary)
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            .padding(.trailing, 18)
            .glassCapsule(interactive: true)
            .glassID(action.id, in: space)
        }
        .glassButtonStyle()
        .transition(pillTransition(delay: delay))
    }

    private func pillTransition(delay: Double) -> AnyTransition {
        let base = AnyTransition.blurFade.combined(with: .scale(scale: 0.4, anchor: .bottomTrailing))
        return .asymmetric(
            insertion: base.animation(Animation.liquid.delay(delay)),
            removal: base.animation(Animation.liquidSnap)
        )
    }

    private func toggle() {
        if !isOpen {
            Haptics.tap()
        }
        isOpen.toggle()
    }

    private func close() {
        isOpen = false
    }

    private func choose(_ action: FloatingAction) {
        Haptics.selection()
        isOpen = false
        action.perform()
    }
}
