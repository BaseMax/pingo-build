import SwiftUI

struct TodoEntryRow: View {
    @Binding var entry: TodoEntry

    var body: some View {
        HStack(spacing: 6) {
            checkbox
            TodoEntryText(text: $entry.text, done: entry.done)
        }
        .padding(.leading, 6)
        .padding(.trailing, 16)
        .padding(.vertical, 4)
        .background { PanelBackground(corner: 22) }
    }

    private var checkbox: some View {
        Button(action: toggle) {
            Image(systemName: entry.done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(entry.done ? Color.leaf : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: entry.done)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(Pressable())
        .accessibilityLabel(entry.done ? "برگردون به انجام‌نشده" : "انجام شد")
    }

    private func toggle() {
        Haptics.tap()
        withAnimation(.liquid) { entry.done.toggle() }
    }
}

struct TodoEntryText: View {
    @Binding var text: String
    let done: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text, prompt: Text("کار بدون اسم").foregroundStyle(Color.secondary))
                .dasto(16)
                .multilineTextAlignment(.leading)
                .submitLabel(.done)
                .foregroundStyle(done ? Color.secondary : Color.primary)
            Text(text)
                .dasto(16)
                .lineLimit(1)
                .foregroundStyle(Color.clear)
                .overlay(alignment: .leading) { strike }
                .allowsHitTesting(false)
        }
        .animation(.liquidSnap, value: done)
    }

    private var strike: some View {
        Rectangle()
            .fill(Color.secondary)
            .frame(height: 1.5)
            .scaleEffect(x: done ? 1 : 0, anchor: .leading)
    }
}
