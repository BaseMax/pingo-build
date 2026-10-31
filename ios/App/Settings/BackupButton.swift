import SwiftUI

struct BackupButton: View {
    private let title: String
    private let symbol: String
    private let prominent: Bool
    private let action: () -> Void

    init(_ title: String, symbol: String, prominent: Bool, action: @escaping () -> Void) {
        self.title = title
        self.symbol = symbol
        self.prominent = prominent
        self.action = action
    }

    var body: some View {
        Button(action: tapped) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(LiquidButtonStyle(prominent: prominent))
    }

    private func tapped() {
        Haptics.tap()
        action()
    }
}
