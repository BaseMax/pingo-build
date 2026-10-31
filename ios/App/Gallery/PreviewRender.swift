import SwiftUI

struct PreviewKey: Equatable {
    let kind: PingoKind
    let size: CardSize
    let selection: WidgetSelection
    let stamp: Date
}

struct PreviewLayers {
    let face: AnyView
    let background: AnyView
}

final class PreviewRender {
    private var key: PreviewKey?
    private var layers: PreviewLayers?

    func layers(for key: PreviewKey) -> PreviewLayers {
        if let layers, self.key == key {
            return layers
        }
        let built = PreviewLayers(
            face: AnyView(key.kind.face(size: key.size, date: key.stamp, selection: key.selection)),
            background: AnyView(key.kind.background(selection: key.selection))
        )
        self.key = key
        layers = built
        return built
    }
}
