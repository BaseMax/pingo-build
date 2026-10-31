import SwiftUI

struct CounterEditorView: View {
    private let id: String
    @State private var draft: CounterItem
    @State private var confetti = 0

    init(id: String) {
        self.id = id
        _draft = State(initialValue: Store.counters.item(id) ?? CounterItem(id: id))
    }

    private var tint: Color {
        Theme.resolved(draft.theme, for: .counter).panelTint
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ItemPreviewHeader(kind: .counter, id: id).editorStage(0)
                CounterTodayPanel(item: draft, tint: tint, onStep: apply).editorStage(1)
                CounterHistoryChart(item: draft, tint: tint).editorStage(2)
                identity.editorStage(3)
                limits.editorStage(4)
                appearance.editorStage(5)
            }
            .padding(.horizontal, Layout.gutter)
            .padding(.top, 8)
        }
        .overlay(alignment: .bottom) {
            ConfettiBurst(trigger: confetti).ignoresSafeArea()
        }
        .liquidScreen()
        .navigationTitle(draft.title.isEmpty ? "شمارنده" : draft.title)
        .navigationBarTitleDisplayMode(.inline)
        .syncsDraft($draft, with: Store.counters)
        .deletesItem(message: "همه شمارش‌های ثبت شده‌ش هم پاک می‌شن.") {
            Store.counters.remove(id)
        }
    }

    private var identity: some View {
        VStack(spacing: 10) {
            SectionTitle("اسم و نماد", symbol: "pencil")
            LiquidTextField("اسم شمارنده، مثلا آب", text: $draft.title, symbol: draft.symbol)
            SymbolPickerRow(Presets.counterSymbols, selection: $draft.symbol)
        }
    }

    private var limits: some View {
        VStack(spacing: 10) {
            SectionTitle("هدف و قدم", symbol: "target")
            LiquidStepperRow("هدف", value: $draft.goal, range: 1...999)
            LiquidStepperRow("هر بار چندتا", value: $draft.step, range: 1...99)
            LiquidToggleRow("صفر شدن روزانه", symbol: "sunrise.fill", isOn: $draft.dailyReset)
        }
    }

    private var appearance: some View {
        VStack(spacing: 10) {
            SectionTitle("رنگ ویجت", symbol: "paintpalette.fill")
            ThemePickerRow(selection: $draft.theme)
        }
    }

    private func apply(_ direction: Int) {
        let hadReached = draft.reachedShownGoal
        let amount: Int = draft.step
        withAnimation(.liquid) {
            draft.step(by: direction * amount, on: .now)
        }
        if direction > 0 && !hadReached && draft.reachedShownGoal {
            confetti += 1
            Haptics.success()
        } else {
            Haptics.tap()
        }
    }
}
