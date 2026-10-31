import SwiftUI

struct LibraryEditButton: View {
    @Binding var editMode: EditMode

    var body: some View {
        Button(editMode.isEditing ? "تموم شد" : "مرتب‌سازی", action: toggle)
    }

    private func toggle() {
        Haptics.selection()
        withAnimation(.liquid) {
            editMode = editMode.isEditing ? .inactive : .active
        }
    }
}
