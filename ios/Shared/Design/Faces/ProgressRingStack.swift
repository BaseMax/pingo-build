import SwiftUI

struct ProgressRingStack: View {
    let slices: [ProgressSlice]
    let palette: FacePalette
    let diameter: CGFloat

    private var lineWidth: CGFloat { diameter * 0.085 }
    private var gap: CGFloat { diameter * 0.03 }

    var body: some View {
        ZStack {
            ForEach(slices) { slice in
                ProgressRing(
                    fraction: slice.value,
                    width: lineWidth,
                    color: palette.rings[slice.id],
                    track: palette.track,
                    delay: Double(slice.id) * 0.09
                )
                .padding(CGFloat(slice.id) * (lineWidth + gap))
            }
        }
        .frame(width: diameter, height: diameter)
    }
}
