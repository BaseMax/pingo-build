import SwiftUI

private struct SwatchButton<Face: View>: View {
    private let caption: String
    private let isSelected: Bool
    private let action: () -> Void
    private let face: Face

    init(caption: String, isSelected: Bool, action: @escaping () -> Void, @ViewBuilder face: () -> Face) {
        self.caption = caption
        self.isSelected = isSelected
        self.action = action
        self.face = face()
    }

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            VStack(spacing: 6) {
                swatch
                Text(caption)
                    .dasto(11)
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
            }
        }
        .buttonStyle(Pressable())
        .animation(.liquid, value: isSelected)
    }

    private var swatch: some View {
        face
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay {
                Circle().strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
            }
            .padding(4)
            .overlay {
                Circle()
                    .strokeBorder(Color.signal, lineWidth: 2.5)
                    .opacity(isSelected ? 1 : 0)
            }
            .scaleEffect(isSelected ? 1.12 : 1)
    }
}

private struct ThemeSwatchStrip: View {
    let selected: Theme?
    let automaticTitle: String?
    let select: (Theme?) -> Void

    private static let automaticID = "automatic"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if let automaticTitle {
                        SwatchButton(caption: automaticTitle, isSelected: selected == nil) {
                            select(nil)
                        } face: {
                            automaticFace
                        }
                        .id(Self.automaticID)
                    }
                    ForEach(Theme.allCases) { theme in
                        SwatchButton(caption: theme.title, isSelected: selected == theme) {
                            select(theme)
                        } face: {
                            LinearGradient(colors: theme.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                        .id(theme.id)
                    }
                }
                .padding(.horizontal, Layout.gutter)
                .padding(.vertical, 14)
            }
            .onAppear {
                proxy.scrollTo(selected?.id ?? Self.automaticID, anchor: .center)
            }
        }
        .background { PanelBackground(corner: Layout.corner) }
    }

    private var automaticFace: some View {
        LinearGradient(
            stops: [
                .init(color: Theme.paper.colors.first ?? Color.white, location: 0.5),
                .init(color: Theme.ink.colors.last ?? Color.black, location: 0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ThemePickerRow: View {
    @Binding private var selection: Theme?
    private let automaticTitle: String

    init(selection: Binding<Theme?>, automaticTitle: String = "خودکار") {
        _selection = selection
        self.automaticTitle = automaticTitle
    }

    var body: some View {
        ThemeSwatchStrip(selected: selection, automaticTitle: automaticTitle) { theme in
            selection = theme
        }
    }
}

struct KindThemePickerRow: View {
    @Binding private var selection: Theme

    init(selection: Binding<Theme>) {
        _selection = selection
    }

    var body: some View {
        ThemeSwatchStrip(selected: selection, automaticTitle: nil) { theme in
            if let theme {
                selection = theme
            }
        }
    }
}

struct SymbolPickerRow: View {
    private let symbols: [String]
    @Binding private var selection: String

    init(_ symbols: [String], selection: Binding<String>) {
        self.symbols = symbols
        _selection = selection
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 46), spacing: 10)], spacing: 10) {
            ForEach(symbols, id: \.self) { symbol in
                SymbolChoice(symbol: symbol, isSelected: selection == symbol) {
                    selection = symbol
                }
            }
        }
        .panel()
    }
}

private struct SymbolChoice: View {
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
    }

    var body: some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .symbolEffect(.bounce, value: isSelected)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(isSelected ? Color.signal : Color.primary.opacity(0.06), in: shape)
        }
        .buttonStyle(Pressable())
        .animation(.liquidSnap, value: isSelected)
    }
}

struct LiquidDateRow: View {
    private let title: String
    @Binding private var date: Date

    init(_ title: String, date: Binding<Date>) {
        self.title = title
        _date = date
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title).dasto(16)
            Spacer(minLength: 8)
            DatePicker(title, selection: $date, displayedComponents: .date)
                .labelsHidden()
                .environment(\.calendar, Persian.calendar)
                .environment(\.locale, Persian.locale)
                .tint(Color.signal)
        }
        .panel()
    }
}
