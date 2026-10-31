import SwiftUI

struct NoteEditorForm: View {
    let id: String
    @Binding var item: NoteItem

    private var text: Binding<String> {
        Binding(
            get: { item.text },
            set: { newValue in
                item.text = newValue
                item.updated = .now
            }
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            LibraryPreviewHeader(kind: .note, id: id)
                .reveal()
            LiquidTextArea("هر چی تو ذهنته بنویس", text: text, minHeight: 200)
                .reveal(0.07)
            ThemePickerRow(selection: $item.theme)
                .reveal(0.14)
            Text("آخرین ویرایش، " + Persian.format(item.updated, "d MMMM، H:mm"))
                .dasto(12)
                .foregroundStyle(Color.secondary)
                .contentTransition(.numericText())
                .animation(.liquidSnap, value: item.updated)
                .reveal(0.21)
        }
        .padding(.horizontal, Layout.gutter)
        .padding(.top, 8)
    }
}
