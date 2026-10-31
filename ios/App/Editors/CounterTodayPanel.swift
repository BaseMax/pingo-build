import SwiftUI

struct CounterTodayPanel: View {
    let item: CounterItem
    let tint: Color
    let onStep: (Int) -> Void

    var body: some View {
        VStack(spacing: 22) {
            ring
            GlassGroup(spacing: 12) {
                HStack(spacing: 12) {
                    minusButton
                    plusButton
                }
            }
        }
        .panel()
        .pingRipple()
    }

    private var ring: some View {
        ZStack {
            CounterProgressRing(progress: item.shownProgress, tint: tint)
            VStack(spacing: 2) {
                Text(Persian.number(item.shownCount))
                    .dasto(60)
                    .contentTransition(.numericText(value: Double(item.shownCount)))
                caption
            }
        }
        .frame(width: 196, height: 196)
        .animation(.liquid, value: item.shownCount)
    }

    @ViewBuilder
    private var caption: some View {
        if item.reachedShownGoal {
            Label("هدف کامل شد", systemImage: "checkmark.seal.fill")
                .dasto(14)
                .foregroundStyle(tint)
                .transition(.blurFade)
        } else {
            Text("از \(Persian.number(item.goal))")
                .dasto(14)
                .foregroundStyle(Color.secondary)
                .transition(.blurFade)
        }
    }

    private var canDecrease: Bool {
        item.count(on: .now) > 0
    }

    private var minusButton: some View {
        Button {
            onStep(-1)
        } label: {
            stepLabel("minus")
        }
        .buttonStyle(.liquid)
        .disabled(!canDecrease)
        .opacity(canDecrease ? 1 : 0.4)
        .animation(.liquidSnap, value: canDecrease)
        .accessibilityLabel("کم کن")
    }

    private var plusButton: some View {
        Button {
            onStep(1)
        } label: {
            stepLabel("plus")
        }
        .buttonStyle(LiquidButtonStyle(prominent: true, tint: tint))
        .accessibilityLabel("اضافه کن")
    }

    private func stepLabel(_ symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .bold))
            Text(Persian.number(item.step))
                .dasto(20)
                .contentTransition(.numericText(value: Double(item.step)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
