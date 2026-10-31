import SwiftUI

struct LiquidSegmented<Value: Hashable>: View {
    private let items: [Value]
    @Binding private var selection: Value
    private let title: (Value) -> String
    @Namespace private var space

    init(_ items: [Value], selection: Binding<Value>, title: @escaping (Value) -> String) {
        self.items = items
        self._selection = selection
        self.title = title
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                segment(item)
            }
        }
        .padding(4)
        .background { pill }
        .background { track }
        .animation(.liquid, value: selection)
    }

    private var track: some View {
        Color.clear.glassCapsule()
    }

    private var pill: some View {
        Color.clear
            .glassCapsule(tint: Color.signal, interactive: true)
            .slidingPill(to: selection, in: space)
    }

    private func segment(_ item: Value) -> some View {
        let isSelected = item == selection
        return Button {
            select(item)
        } label: {
            Text(title(item))
                .dasto(14)
                .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 40)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .slideSource(item, in: space)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func select(_ item: Value) {
        guard item != selection else { return }
        Haptics.selection()
        selection = item
    }
}
