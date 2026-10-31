import SwiftUI
import WidgetKit

struct FaceNotice: View {
    let kind: FaceNoticeKind
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }

    private var symbol: String {
        switch kind {
        case .groupUnreachable: "exclamationmark.triangle.fill"
        case .chooseItem: "hand.tap.fill"
        }
    }

    private var title: String {
        switch kind {
        case .groupUnreachable: GroupCopy.widgetTitle
        case .chooseItem: GroupCopy.chooseTitle
        }
    }

    private var detail: String {
        switch kind {
        case .groupUnreachable: GroupCopy.widgetDetail
        case .chooseItem: GroupCopy.chooseDetail
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 26))
                .foregroundStyle(palette.accent)
                .faceAccent()
            Text(title)
                .dasto(14)
                .foregroundStyle(palette.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(detail)
                .dasto(size == .small ? 10 : 12)
                .foregroundStyle(palette.soft)
                .multilineTextAlignment(.center)
                .lineLimit(5)
                .minimumScaleFactor(0.7)
        }
        .taskFaceFrame(size)
    }
}
