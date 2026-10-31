import SwiftUI

struct LockScreenRow: View {
    let kind: PingoKind

    var body: some View {
        VStack(spacing: 12) {
            SectionTitle("صفحه قفل", symbol: "lock.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(kind.accessories, id: \.self) { shape in
                        item(shape)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
        }
    }

    private func item(_ shape: AccessoryShape) -> some View {
        VStack(spacing: 8) {
            AccessoryPreview(kind: kind, shape: shape)
            Text(shape.title)
                .dasto(12)
                .foregroundStyle(Color.secondary)
        }
    }
}
