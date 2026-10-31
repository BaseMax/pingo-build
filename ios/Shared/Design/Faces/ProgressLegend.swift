import SwiftUI

struct ProgressLegend: View {
    let slices: [ProgressSlice]
    let palette: FacePalette

    var body: some View {
        VStack(spacing: 0) {
            ForEach(slices) { slice in
                HStack(spacing: 8) {
                    Circle()
                        .fill(palette.rings[slice.id])
                        .frame(width: 9, height: 9)
                        .faceAccent()
                    Text(slice.title)
                        .dasto(14)
                        .foregroundStyle(palette.soft)
                    Spacer(minLength: 0)
                    Text(slice.percent)
                        .dasto(16)
                        .foregroundStyle(palette.ink)
                        .lineLimit(1)
                        .contentTransition(.numericText())
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
