import SwiftUI
import WidgetKit

struct MoonAccessory: View {
    let phase: MoonPhase

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            MoonDisc(fraction: phase.fraction, colors: .accessory)
                .padding(7)
                .widgetAccentable()
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
