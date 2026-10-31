import SwiftUI

struct KindDetailView: View {
    let kind: PingoKind

    @Environment(AppRouter.self) private var router
    @State private var size: CardSize
    @State private var theme: Theme
    @State private var succeeded: Bool
    @State private var confetti = 0

    init(kind: PingoKind) {
        self.kind = kind
        _size = State(initialValue: kind.sizes.first ?? .small)
        _theme = State(initialValue: Store.theme(for: kind))
        _succeeded = State(initialValue: KindSuccess.isReached(kind))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                stage.reveal()
                if kind.sizes.count > 1 {
                    LiquidSegmented(kind.sizes, selection: $size) { $0.title }.reveal(0.06)
                }
                about.reveal(0.1)
                if !kind.accessories.isEmpty {
                    LockScreenRow(kind: kind).reveal(0.14)
                }
                KindThemePickerRow(selection: themeBinding).reveal(0.18)
                if KindOptions.applies(to: kind) {
                    KindOptions(kind: kind).reveal(0.22)
                }
                if kind.library != nil {
                    ItemsSection(kind: kind).reveal(0.26)
                }
                addButton.reveal(0.3)
            }
            .padding(.horizontal, Layout.gutter)
            .padding(.top, 8)
        }
        .liquidScreen()
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: .pingoStoreChanged)) { _ in
            celebrateIfReached()
        }
        .reloadsOnActive { theme = Store.theme(for: kind) }
    }

    private var themeBinding: Binding<Theme> {
        Binding(
            get: { theme },
            set: { new in
                theme = new
                Store.setTheme(new, for: kind)
            }
        )
    }

    private var stage: some View {
        ZStack {
            FacePreview(kind: kind, size: size)
                .id(size)
                .transition(.blurFade)
        }
        .frame(width: size.points.width, height: size.points.height)
        .tiltParallax()
        .rubberBand()
        .frame(maxWidth: .infinity)
        .frame(height: size.points.height + 40)
        .animation(.liquid, value: size)
        .overlay { ConfettiBurst(trigger: confetti) }
    }

    private var about: some View {
        Text(kind.about)
            .dasto(14)
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var addButton: some View {
        Button {
            router.open(.guide(kind))
        } label: {
            Label("افزودن به صفحه اصلی", systemImage: "plus.square.on.square")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.liquidProminent)
        .padding(.top, 4)
    }

    private func celebrateIfReached() {
        let reached = KindSuccess.isReached(kind)
        if reached && !succeeded {
            confetti += 1
            Haptics.success()
        }
        succeeded = reached
    }
}
