import SwiftUI
import WidgetKit

@main
struct PingoWidgets: WidgetBundle {
    var body: some Widget {
        timeWidgets
        taskWidgets
        inspireWidgets
        controls
    }

    @WidgetBundleBuilder private var timeWidgets: some Widget {
        PingoWidget<DateSpec>()
        PingoWidget<ClockSpec>()
        PingoWidget<ProgressSpec>()
        PingoWidget<CountdownSpec>()
        PingoWidget<MoonSpec>()
    }

    @WidgetBundleBuilder private var taskWidgets: some Widget {
        PingoWidget<NoteSpec>()
        PingoWidget<TodoSpec>()
        PingoWidget<HabitSpec>()
        PingoWidget<CounterSpec>()
    }

    @WidgetBundleBuilder private var inspireWidgets: some Widget {
        PingoWidget<PhotoSpec>()
        PingoWidget<FalSpec>()
    }

    @WidgetBundleBuilder private var controls: some Widget {
        HabitControl()
        CounterControl()
    }
}
