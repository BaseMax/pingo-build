import SwiftUI
import WidgetKit

struct MoonFace: View {
    let phase: MoonPhase
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }

    var body: some View {
        layout
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder private var layout: some View {
        if size == .small {
            MoonSmall(phase: phase, palette: palette)
        } else {
            MoonMedium(phase: phase, palette: palette)
        }
    }
}

struct MoonSmall: View {
    let phase: MoonPhase
    let palette: FacePalette

    var body: some View {
        VStack(spacing: 8) {
            MoonDisc(fraction: phase.fraction, colors: MoonColors(palette: palette))
                .frame(width: 84, height: 84)
                .faceAccent()
            Text(phase.name)
                .dasto(15)
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

struct MoonMedium: View {
    let phase: MoonPhase
    let palette: FacePalette

    var body: some View {
        HStack(spacing: 20) {
            MoonDisc(fraction: phase.fraction, colors: MoonColors(palette: palette))
                .frame(width: 112, height: 112)
                .faceAccent()
            details
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(phase.name)
                .dasto(24)
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("روشنایی " + Persian.percent(phase.illumination))
                .dasto(14)
                .foregroundStyle(palette.soft)
            Text("سن ماه " + Persian.number(phase.age) + " روز")
                .dasto(14)
                .foregroundStyle(palette.soft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
