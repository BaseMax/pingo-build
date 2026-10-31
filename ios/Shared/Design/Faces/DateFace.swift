import SwiftUI
import WidgetKit

struct DateFace: View {
    let date: Date
    let size: CardSize
    let theme: Theme
    let showsGregorian: Bool

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }

    var body: some View {
        content.timeFaceFrame(size, alignment: .topLeading)
    }

    @ViewBuilder
    private var content: some View {
        switch size {
        case .small: summary(font: 64, height: 60)
        case .medium: medium
        case .large: large
        }
    }

    private func summary(font: CGFloat, height: CGFloat) -> some View {
        DateSummary(date: date, palette: palette, showsGregorian: showsGregorian, dayFont: font, dayHeight: height)
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 14) {
            summary(font: 54, height: 52).frame(width: 104)
            grid(width: size.timeContent.width - 118, height: size.timeContent.height, cell: 11, header: 10)
        }
    }

    private var large: some View {
        VStack(spacing: 14) {
            DateHeader(date: date, palette: palette, showsGregorian: showsGregorian)
            grid(width: size.timeContent.width, height: size.timeContent.height - 88, cell: 15, header: 12)
        }
    }

    private func grid(width: CGFloat, height: CGFloat, cell: CGFloat, header: CGFloat) -> some View {
        DateMonthGrid(date: date, palette: palette, width: width, height: height, cellFont: cell, headerFont: header)
    }
}
