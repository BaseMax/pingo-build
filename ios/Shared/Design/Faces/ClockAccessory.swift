import SwiftUI
import WidgetKit

struct ClockAccessory: View {
    let date: Date

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            GeometryReader { proxy in
                ClockDial(date: date, palette: .system, diameter: min(proxy.size.width, proxy.size.height) * 0.86, showsFace: false)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
