import SwiftUI

struct HabitDayCell: View {
    let day: Int
    let done: Bool
    let isToday: Bool
    let isFuture: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(Persian.number(day))
                .dasto(14)
                .foregroundStyle(done ? Color.white : Color.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background { fill }
                .overlay { todayRing }
        }
        .buttonStyle(Pressable())
        .disabled(isFuture)
        .opacity(isFuture ? 0.3 : 1)
        .animation(.liquidStretch, value: done)
        .accessibilityLabel("روز " + Persian.number(day))
        .accessibilityValue(done ? "ثبت شده" : "ثبت نشده")
        .accessibilityAddTraits(done ? .isSelected : [])
    }

    private var fill: some View {
        Circle()
            .fill(done ? tint : Color.primary.opacity(0.06))
            .scaleEffect(done ? 1 : 0.88)
    }

    private var todayRing: some View {
        Circle()
            .strokeBorder(tint, lineWidth: 2)
            .padding(done ? -4 : 0)
            .opacity(isToday ? 1 : 0)
    }
}
