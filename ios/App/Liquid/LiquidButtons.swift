import SwiftUI

struct LiquidButtonStyle: ButtonStyle {
    private let prominent: Bool
    private let tint: Color?
    private let isCircle: Bool

    init(prominent: Bool = false, tint: Color? = nil) {
        self.init(prominent: prominent, tint: tint, isCircle: false)
    }

    init(prominent: Bool, tint: Color?, isCircle: Bool) {
        self.prominent = prominent
        self.tint = tint
        self.isCircle = isCircle
    }

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        return surface(
            configuration.label
                .dasto(16)
                .foregroundStyle(prominent ? Color.white : Color.primary)
                .blur(radius: pressed ? 1.2 : 0)
        )
        .scaleEffect(pressed ? 0.94 : 1)
        .animation(Animation.liquid, value: pressed)
        .onChange(of: pressed) { _, isDown in
            if isDown {
                Haptics.soft()
            }
        }
    }

    private var glassTint: Color? {
        if prominent {
            return tint ?? Color.signal
        }
        return tint
    }

    @ViewBuilder
    private func surface(_ label: some View) -> some View {
        if isCircle {
            label
                .frame(width: 44, height: 44)
                .glassCircle(tint: glassTint, interactive: true)
        } else {
            label
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .glassCapsule(tint: glassTint, interactive: true)
        }
    }
}

extension ButtonStyle where Self == LiquidButtonStyle {
    static var liquid: LiquidButtonStyle { LiquidButtonStyle() }
    static var liquidProminent: LiquidButtonStyle { LiquidButtonStyle(prominent: true) }
}

struct LiquidIconButton: View {
    private let symbol: String
    private let tint: Color?
    private let action: () -> Void

    init(symbol: String, tint: Color? = nil, action: @escaping () -> Void) {
        self.symbol = symbol
        self.tint = tint
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
        }
        .buttonStyle(LiquidButtonStyle(prominent: tint != nil, tint: tint, isCircle: true))
    }
}

struct ToolbarIconButton: View {
    private let symbol: String
    private let action: () -> Void

    init(symbol: String, action: @escaping () -> Void) {
        self.symbol = symbol
        self.action = action
    }

    var body: some View {
        if SystemGlass.isActive {
            Button {
                Haptics.tap()
                action()
            } label: {
                Image(systemName: symbol)
            }
        } else {
            LiquidIconButton(symbol: symbol, action: action)
        }
    }
}
