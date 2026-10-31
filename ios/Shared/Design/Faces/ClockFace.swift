import SwiftUI
import WidgetKit

struct ClockFace: View {
    let date: Date
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }
    private var diameter: CGFloat { size.timeContent.height }

    var body: some View {
        content.timeFaceFrame(size)
    }

    @ViewBuilder
    private var content: some View {
        if size == .small {
            ClockDial(date: date, palette: palette, diameter: diameter)
        } else {
            HStack(spacing: 18) {
                ClockDial(date: date, palette: palette, diameter: diameter)
                ClockDigital(date: date, palette: palette)
            }
        }
    }
}
