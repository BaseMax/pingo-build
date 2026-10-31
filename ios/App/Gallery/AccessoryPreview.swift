import SwiftUI

struct AccessoryPreview: View {
    private let kind: PingoKind
    private let shape: AccessoryShape
    private let selection: WidgetSelection

    @State private var stamp = Date.now

    init(kind: PingoKind, shape: AccessoryShape, selection: WidgetSelection = WidgetSelection()) {
        self.kind = kind
        self.shape = shape
        self.selection = selection
    }

    var body: some View {
        kind.accessoryFace(shape: shape, date: stamp, selection: selection)
            .foregroundStyle(Color.white)
            .tint(Color.white)
            .environment(\.layoutDirection, .rightToLeft)
            .padding(.horizontal, shape == .inline ? 12 : 0)
            .frame(width: plateSize.width, height: plateSize.height)
            .background { plate }
            .clipShape(plateShape)
            .refreshesOnStoreChange($stamp)
            .ticksEveryMinute(kind == .clock, stamp: $stamp)
    }

    private var plateSize: CGSize {
        switch shape {
        case .circular: CGSize(width: 76, height: 76)
        case .rectangular: CGSize(width: 160, height: 76)
        case .inline: CGSize(width: 220, height: 32)
        }
    }

    private var plateShape: AnyShape {
        switch shape {
        case .circular: AnyShape(Circle())
        case .rectangular: AnyShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        case .inline: AnyShape(Capsule())
        }
    }

    private var plate: some View {
        plateShape
            .fill(Color.black.opacity(0.55))
            .overlay {
                plateShape.stroke(Color.white.opacity(0.14), lineWidth: 0.5)
            }
    }
}
