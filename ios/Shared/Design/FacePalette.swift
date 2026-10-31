import SwiftUI
import WidgetKit

struct FacePalette {
    let theme: Theme
    let isFullColor: Bool

    init(theme: Theme, mode: WidgetRenderingMode) {
        self.theme = theme
        self.isFullColor = mode == .fullColor
    }

    static let system = FacePalette(theme: .ink, mode: .vibrant)

    var ink: Color { isFullColor ? theme.ink : Color.primary }
    var soft: Color { isFullColor ? theme.soft : Color.secondary }
    var track: Color { isFullColor ? theme.track : Color.primary.opacity(0.18) }
    var accent: Color { isFullColor ? theme.accent : Color.primary }
    var onAccent: Color { isFullColor ? theme.onAccent : Color.black.opacity(0.85) }

    var rings: [Color] {
        isFullColor ? theme.rings : [1.0, 0.75, 0.5, 0.3].map { Color.primary.opacity($0) }
    }
}

extension View {
    func faceAccent() -> some View {
        widgetAccentable()
    }
}
