import SwiftUI

struct RowSymbolTile: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.white)
            .frame(width: 30, height: 30)
            .background(Color.signal, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

struct LiquidToggleRow: View {
    private let title: String
    private let symbol: String?
    @Binding private var isOn: Bool

    init(_ title: String, symbol: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.symbol = symbol
        _isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                if let symbol {
                    RowSymbolTile(symbol: symbol)
                }
                Text(title).dasto(16)
            }
        }
        .tint(Color.signal)
        .panel()
        .onChange(of: isOn) { _, _ in
            Haptics.selection()
        }
    }
}

struct LiquidStepperRow: View {
    private let title: String
    private let range: ClosedRange<Int>
    private let step: Int
    private let format: ((Int) -> String)?
    @Binding private var value: Int

    init(_ title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1, format: ((Int) -> String)? = nil) {
        self.title = title
        self.range = range
        self.step = step
        self.format = format
        _value = value
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title).dasto(16)
            Spacer(minLength: 8)
            Text(format?(value) ?? Persian.number(value))
                .dasto(16)
                .contentTransition(.numericText())
                .animation(.liquidSnap, value: value)
            GlassGroup(spacing: 8) {
                HStack(spacing: 10) {
                    StepperButton(symbol: "minus", label: "کم کن", isEnabled: value > range.lowerBound) {
                        move(by: -step)
                    }
                    StepperButton(symbol: "plus", label: "اضافه کن", isEnabled: value < range.upperBound) {
                        move(by: step)
                    }
                }
            }
        }
        .panel()
    }

    private func move(by delta: Int) {
        let next = min(max(value + delta, range.lowerBound), range.upperBound)
        guard next != value else { return }
        value = next
        Haptics.selection()
    }
}

private struct StepperButton: View {
    let symbol: String
    let label: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.primary)
                .frame(width: 38, height: 38)
                .glassCircle(interactive: true)
        }
        .buttonStyle(Pressable())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .animation(.liquidSnap, value: isEnabled)
        .accessibilityLabel(label)
    }
}

struct LiquidRow<Leading: View, Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let leading: Leading
    private let trailing: Trailing

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .dasto(16)
                    .foregroundStyle(Color.primary)
                if let subtitle {
                    Text(subtitle)
                        .dasto(13)
                        .foregroundStyle(Color.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .panel()
        .contentShape(RoundedRectangle(cornerRadius: Layout.corner, style: .continuous))
    }
}
