import SwiftUI

struct CountdownEditorForm: View {
    let id: String
    @Binding var item: CountdownItem

    var body: some View {
        VStack(spacing: 14) {
            LibraryPreviewHeader(kind: .countdown, id: id)
                .reveal()
            LiquidTextField("اسم رویداد", text: $item.title, symbol: "textformat")
                .reveal(0.07)
            SymbolPickerRow(Presets.countdownSymbols, selection: $item.symbol)
                .reveal(0.14)
            LiquidDateRow("تاریخ", date: $item.date)
                .reveal(0.21)
            CountdownRemainingCard(remaining: CountdownRemaining(date: item.date))
                .reveal(0.28)
            ThemePickerRow(selection: $item.theme)
                .reveal(0.35)
        }
        .padding(.horizontal, Layout.gutter)
        .padding(.top, 8)
    }
}
