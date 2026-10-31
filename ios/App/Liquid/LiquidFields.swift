import SwiftUI

private struct FieldChrome: ViewModifier {
    let focused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .background { PanelBackground(corner: 20) }
            .overlay {
                shape
                    .strokeBorder(Color.signal, lineWidth: 2)
                    .opacity(focused ? 1 : 0)
            }
            .contentShape(shape)
            .scaleEffect(focused && !reduceMotion ? 1.01 : 1)
            .animation(.liquidSnap, value: focused)
    }
}

private extension View {
    func fieldChrome(focused: Bool) -> some View {
        modifier(FieldChrome(focused: focused))
    }
}

struct LiquidTextField: View {
    private let placeholder: String
    private let symbol: String?
    @Binding private var text: String
    @FocusState private var focused: Bool

    init(_ placeholder: String, text: Binding<String>, symbol: String? = nil) {
        self.placeholder = placeholder
        self.symbol = symbol
        _text = text
    }

    var body: some View {
        HStack(spacing: 10) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(focused ? Color.signal : Color.secondary)
                    .animation(.liquidSnap, value: focused)
            }
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color.secondary))
                .dasto(16)
                .multilineTextAlignment(.leading)
                .submitLabel(.done)
                .focused($focused)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .fieldChrome(focused: focused)
        .onTapGesture { focused = true }
    }
}

struct LiquidTextArea: View {
    private let placeholder: String
    private let minHeight: CGFloat
    @Binding private var text: String
    @FocusState private var focused: Bool

    init(_ placeholder: String, text: Binding<String>, minHeight: CGFloat = 140) {
        self.placeholder = placeholder
        self.minHeight = minHeight
        _text = text
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .dasto(16)
                .scrollContentBackground(.hidden)
                .focused($focused)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            if text.isEmpty {
                Text(placeholder)
                    .dasto(16)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
                    .transition(.blurFade)
            }
        }
        .frame(minHeight: minHeight)
        .animation(.liquidSnap, value: text.isEmpty)
        .fieldChrome(focused: focused)
    }
}
