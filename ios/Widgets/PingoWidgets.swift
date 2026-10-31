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
        PingoWidget<ThemeConfigIntent>(kind: .date)
        PingoWidget<ThemeConfigIntent>(kind: .clock)
        PingoWidget<ThemeConfigIntent>(kind: .progress)
        PingoWidget<CountdownConfigIntent>(kind: .countdown)
        PingoWidget<ThemeConfigIntent>(kind: .moon)
    }

    @WidgetBundleBuilder private var taskWidgets: some Widget {
        PingoWidget<NoteConfigIntent>(kind: .note)
        PingoWidget<TodoConfigIntent>(kind: .todo)
        PingoWidget<HabitConfigIntent>(kind: .habit)
        PingoWidget<CounterConfigIntent>(kind: .counter)
    }

    @WidgetBundleBuilder private var inspireWidgets: some Widget {
        PingoWidget<AlbumConfigIntent>(kind: .photo)
        PingoWidget<ThemeConfigIntent>(kind: .fal)
    }

    @WidgetBundleBuilder private var controls: some Widget {
        HabitControl()
        CounterControl()
    }
}
