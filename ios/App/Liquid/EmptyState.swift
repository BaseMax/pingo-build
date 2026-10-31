import SwiftUI

struct EmptyState: View {
    private let symbol: String
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false

    init(symbol: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 12) {
            glyph
            Text(title).dasto(20)
            Text(message)
                .dasto(14)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            actionButton
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .reveal()
        .onAppear(perform: startFloating)
    }

    private var glyph: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.signal.opacity(0.26), Color.signal.opacity(0)],
                        center: .center,
                        startRadius: 4,
                        endRadius: 86
                    )
                )
                .frame(width: 172, height: 172)
            Image(systemName: symbol)
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(Color.signal)
                .symbolEffect(.pulse, isActive: !reduceMotion)
        }
        .offset(y: reduceMotion ? 0 : (floating ? -5 : 5))
        .padding(.bottom, 4)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var actionButton: some View {
        if let actionTitle, let action {
            Button(actionTitle, action: action)
                .buttonStyle(.liquidProminent)
                .padding(.top, 8)
        }
    }

    private func startFloating() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
            floating = true
        }
    }
}
