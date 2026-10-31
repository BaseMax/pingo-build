import SwiftUI

struct TodoAddRow: View {
    let onAdd: (String) -> Void

    @State private var text = ""
    @FocusState private var focused: Bool

    private var canAdd: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(focused ? Color.signal : Color.secondary)
            field
            if canAdd {
                addButton.transition(.blurFade)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background { PanelBackground(corner: 20) }
        .overlay {
            shape
                .strokeBorder(Color.signal, lineWidth: 2)
                .opacity(focused ? 1 : 0)
        }
        .contentShape(shape)
        .onTapGesture { focused = true }
        .animation(.liquidSnap, value: focused)
        .animation(.liquidSnap, value: canAdd)
    }

    private var field: some View {
        TextField("", text: $text, prompt: Text("یه کار جدید").foregroundStyle(Color.secondary))
            .dasto(16)
            .multilineTextAlignment(.leading)
            .submitLabel(.done)
            .focused($focused)
            .onSubmit(submit)
    }

    private var addButton: some View {
        Button(action: submit) {
            Image(systemName: "arrow.up")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 30, height: 30)
                .background(Color.signal, in: Circle())
        }
        .buttonStyle(Pressable())
        .accessibilityLabel("اضافه کن")
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Haptics.soft()
        onAdd(trimmed)
        text = ""
        Task { @MainActor in focused = true }
    }
}
