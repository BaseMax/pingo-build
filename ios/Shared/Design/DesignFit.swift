import SwiftUI

struct DesignFit: ViewModifier {
    let design: CGSize
    let alignment: Alignment

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .frame(width: design.width, height: design.height, alignment: alignment)
                .scaleEffect(scale(in: proxy.size))
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func scale(in container: CGSize) -> CGFloat {
        guard container.width > 0, container.height > 0, design.width > 0, design.height > 0 else { return 1 }
        return min(container.width / design.width, container.height / design.height)
    }
}

extension View {
    func fitsDesign(_ design: CGSize, alignment: Alignment = .center) -> some View {
        modifier(DesignFit(design: design, alignment: alignment))
    }
}
