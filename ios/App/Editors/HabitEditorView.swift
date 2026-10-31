import SwiftUI

struct HabitEditorView: View {
    private let id: String
    @State private var draft: HabitItem
    @State private var confetti = 0

    init(id: String) {
        self.id = id
        _draft = State(initialValue: Store.habits.item(id) ?? HabitItem(id: id))
    }

    private var tint: Color {
        Theme.resolved(draft.theme, for: .habit).panelTint
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ItemPreviewHeader(kind: .habit, id: id).editorStage(0)
                HabitTodayButton(done: draft.isDone(.now), tint: tint) { toggle(.now) }.editorStage(1)
                HabitStatsPanel(item: draft, tint: tint).editorStage(2)
                HabitCalendar(item: draft, tint: tint, onToggle: toggle).editorStage(3)
                form
            }
            .padding(.horizontal, Layout.gutter)
            .padding(.top, 8)
        }
        .overlay(alignment: .bottom) {
            ConfettiBurst(trigger: confetti).ignoresSafeArea()
        }
        .liquidScreen()
        .navigationTitle(draft.title.isEmpty ? "عادت" : draft.title)
        .navigationBarTitleDisplayMode(.inline)
        .syncsDraft($draft, with: Store.habits)
        .deletesItem(message: "همه روزهای ثبت شده‌ش هم پاک می‌شن.") {
            Store.habits.remove(id)
        }
    }

    private var form: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                SectionTitle("اسم و نماد", symbol: "pencil")
                LiquidTextField("اسم عادت، مثلا ورزش صبحگاهی", text: $draft.title, symbol: draft.symbol)
                SymbolPickerRow(Presets.habitSymbols, selection: $draft.symbol)
            }
            .editorStage(4)
            VStack(spacing: 10) {
                SectionTitle("رنگ ویجت", symbol: "paintpalette.fill")
                ThemePickerRow(selection: $draft.theme)
            }
            .editorStage(5)
        }
    }

    private func toggle(_ date: Date) {
        let wasDone = draft.isDone(date)
        withAnimation(.liquidStretch) {
            draft.toggle(date)
        }
        if !wasDone && Persian.daysBetween(date, .now) == 0 {
            confetti += 1
            Haptics.success()
        } else {
            Haptics.soft()
        }
    }
}
