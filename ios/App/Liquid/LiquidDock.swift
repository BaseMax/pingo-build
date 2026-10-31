import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case gallery, library, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gallery: return "ویجت‌ها"
        case .library: return "کتابخانه"
        case .settings: return "تنظیمات"
        }
    }

    var symbol: String {
        switch self {
        case .gallery: return "square.grid.2x2.fill"
        case .library: return "tray.full.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct LiquidDock: View {
    @Binding private var selection: AppTab
    @Namespace private var space
    @Environment(\.colorScheme) private var colorScheme

    init(selection: Binding<AppTab>) {
        self._selection = selection
    }

    var body: some View {
        GlassGroup(spacing: 10) {
            HStack(spacing: 2) {
                ForEach(AppTab.allCases) { tab in
                    item(tab)
                }
            }
            .padding(6)
            .background { pill }
            .background { track }
            .animation(.liquid, value: selection)
        }
        .padding(.horizontal, Layout.gutter)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var selectedColor: Color {
        colorScheme == .dark ? Color.signal : Color(hex: 0xA33800)
    }

    private var track: some View {
        Color.clear.glassCapsule()
    }

    private var pill: some View {
        Color.clear
            .glassCapsule(tint: Color.signal.opacity(0.28), interactive: true)
            .slidingPill(to: selection, in: space)
    }

    private func item(_ tab: AppTab) -> some View {
        let isSelected = tab == selection
        return Button {
            select(tab)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.symbol)
                    .font(.system(size: 19, weight: .semibold))
                    .symbolEffect(.bounce, value: selection)
                if isSelected {
                    Text(tab.title)
                        .dasto(12)
                        .lineLimit(1)
                        .transition(.blurFade)
                }
            }
            .foregroundStyle(isSelected ? selectedColor : Color.secondary)
            .padding(.horizontal, 16)
            .frame(minWidth: 56, minHeight: 48)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .slideSource(tab, in: space)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func select(_ tab: AppTab) {
        guard tab != selection else { return }
        Haptics.selection()
        selection = tab
    }
}
