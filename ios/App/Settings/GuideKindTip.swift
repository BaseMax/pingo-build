import SwiftUI

struct GuideKindTip: View {
    let kind: PingoKind

    private var interaction: String {
        kind.isInteractive
            ? "مستقیم از روی صفحه اصلی لمسش می‌کنی و جواب می‌گیری."
            : "فقط نگاهش می‌کنی و با یه لمس وارد پینگو می‌شی."
    }

    private var sizes: String {
        "سایزها: " + kind.sizes.map(\.title).joined(separator: "، ")
    }

    private var lock: String {
        kind.accessories.isEmpty
            ? "این ویجت فقط برای صفحه اصلیه."
            : "صفحه قفل: " + kind.accessories.map(\.title).joined(separator: "، ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            line(kind.isInteractive ? "hand.point.up.left.fill" : "eye.fill", interaction)
            line("rectangle.3.group.fill", sizes)
            line("lock.fill", lock)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .panel()
    }

    private var header: some View {
        HStack(spacing: 12) {
            RowSymbolTile(symbol: kind.symbol)
            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title).dasto(18)
                Text(kind.about)
                    .dasto(13)
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private func line(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.signal)
                .frame(width: 20)
            Text(text)
                .dasto(14)
                .foregroundStyle(Color.primary.opacity(0.8))
                .lineSpacing(3)
        }
    }
}
