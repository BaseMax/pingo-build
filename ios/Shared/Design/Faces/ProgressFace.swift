import SwiftUI
import WidgetKit

struct ProgressFace: View {
    let date: Date
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }
    private var slices: [ProgressSlice] { ProgressSlice.all(at: date) }
    private var diameter: CGFloat { size.timeContent.height }

    var body: some View {
        content.timeFaceFrame(size)
    }

    @ViewBuilder
    private var content: some View {
        if size == .small {
            ProgressRingStack(slices: slices, palette: palette, diameter: diameter)
        } else {
            HStack(spacing: 22) {
                ProgressRingStack(slices: slices, palette: palette, diameter: diameter)
                ProgressLegend(slices: slices, palette: palette)
            }
        }
    }
}
