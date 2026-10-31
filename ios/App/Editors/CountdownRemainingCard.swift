import SwiftUI

struct CountdownRemainingCard: View {
    let remaining: CountdownRemaining

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if remaining.showsNumber {
                Text(remaining.number)
                    .dasto(34)
                    .contentTransition(.numericText())
            }
            Text(remaining.phrase)
                .dasto(16)
                .foregroundStyle(Color.secondary)
                .contentTransition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panel()
        .animation(.liquid, value: remaining)
    }
}
