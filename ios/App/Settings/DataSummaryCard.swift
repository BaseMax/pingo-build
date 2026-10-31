import SwiftUI

struct DataSummaryCard: View {
    @State private var counts = DataSummaryCard.current()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(LibraryKind.allCases) { kind in
                tile(kind)
            }
        }
        .panel()
        .animation(.liquid, value: counts)
        .onReceive(NotificationCenter.default.publisher(for: .pingoStoreChanged)) { _ in
            counts = Self.current()
        }
        .reloadsOnActive { counts = Self.current() }
    }

    private func tile(_ kind: LibraryKind) -> some View {
        VStack(spacing: 6) {
            Image(systemName: kind.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.signal)
            Text(Persian.number(counts[kind] ?? 0))
                .dasto(22)
                .contentTransition(.numericText())
            Text(kind.plural)
                .dasto(12)
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private static func current() -> [LibraryKind: Int] {
        Dictionary(uniqueKeysWithValues: LibraryKind.allCases.map { ($0, Store.count(of: $0)) })
    }
}
