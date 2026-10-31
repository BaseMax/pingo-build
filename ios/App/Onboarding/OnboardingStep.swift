import SwiftUI

struct OnboardingStep: Identifiable {
    let symbol: String
    let title: String
    let detail: String

    var id: String { symbol }

    static let all: [OnboardingStep] = [
        OnboardingStep(symbol: "hand.tap.fill", title: "صفحه اصلی رو نگه دار", detail: "یه جای خالی رو چند ثانیه نگه دار تا آیکون‌ها بلرزن"),
        OnboardingStep(symbol: "plus.circle.fill", title: "روی + بزن", detail: "دکمه + گوشه بالای صفحه‌ست"),
        OnboardingStep(symbol: "square.grid.2x2.fill", title: "پینگو رو انتخاب کن", detail: "ویجتت رو پیدا کن و اضافه‌ش کن")
    ]
}

struct OnboardingStepRow: View {
    let index: Int
    let step: OnboardingStep
    let isActive: Bool

    var body: some View {
        LiquidRow(title: step.title, subtitle: step.detail) {
            RowSymbolTile(symbol: step.symbol)
                .symbolEffect(.bounce, value: isActive)
        } trailing: {
            Text(Persian.number(index + 1))
                .dasto(16)
                .foregroundStyle(isActive ? Color.signal : Color.secondary)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Layout.corner, style: .continuous)
                .strokeBorder(Color.signal.opacity(isActive ? 0.7 : 0), lineWidth: 1.5)
        }
        .scaleEffect(isActive ? 1.02 : 1)
        .animation(.liquid, value: isActive)
    }
}
