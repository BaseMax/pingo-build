import SwiftUI

struct HabitTodayButton: View {
    let done: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: done ? "checkmark.circle.fill" : "circle.dotted")
                    .font(.system(size: 22, weight: .semibold))
                    .symbolEffect(.bounce, value: done)
                    .contentTransition(.symbolEffect(.replace))
                Text(done ? "امروز ثبت شد" : "ثبت امروز")
                    .dasto(20)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(LiquidButtonStyle(prominent: true, tint: tint))
        .animation(.liquid, value: done)
        .accessibilityLabel(done ? "امروز ثبت شد، لغو" : "ثبت امروز")
    }
}
