import SwiftUI
import WidgetKit
import AppIntents

struct HabitControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "ir.dsto.pingo.control.habit") {
            ControlWidgetButton(action: ToggleFirstHabitIntent()) {
                Label("ثبت امروز", systemImage: "flame.fill")
            }
        }
        .displayName("ثبت امروز")
        .description("عادت اولت رو برای امروز ثبت می‌کنه")
    }
}

struct CounterControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "ir.dsto.pingo.control.counter") {
            ControlWidgetButton(action: CountFirstCounterIntent()) {
                Label("یک شمارش", systemImage: "plus.circle.fill")
            }
        }
        .displayName("یک شمارش")
        .description("به شمارنده اولت یکی اضافه می‌کنه")
    }
}
