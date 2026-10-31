import SwiftUI

extension View {
    func glass<S: Shape>(_ shape: S, tint: Color? = nil, interactive: Bool = false) -> some View {
        modifier(GlassSurface(shape: shape, tint: tint, interactive: interactive))
    }

    func glassCapsule(tint: Color? = nil, interactive: Bool = false) -> some View {
        glass(Capsule(), tint: tint, interactive: interactive)
    }

    func glassCircle(tint: Color? = nil, interactive: Bool = false) -> some View {
        glass(Circle(), tint: tint, interactive: interactive)
    }

    func glassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        modifier(GlassIdentity(id: id, namespace: namespace))
    }
}

enum SystemGlass {
    static let isActive: Bool = {
        #if compiler(>=6.2) && !PINGO_LEGACY_GLASS
        if #available(iOS 26, *) {
            return true
        }
        #endif
        return false
    }()
}

struct GlassGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    init(spacing: CGFloat = 12, @ViewBuilder _ content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        #if compiler(>=6.2) && !PINGO_LEGACY_GLASS
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
        #else
        content
        #endif
    }
}

private struct GlassSurface<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color?
    let interactive: Bool

    func body(content: Content) -> some View {
        #if compiler(>=6.2) && !PINGO_LEGACY_GLASS
        if #available(iOS 26, *) {
            content.glassEffect(Glass.build(tint: tint, interactive: interactive), in: shape)
        } else {
            content.modifier(MaterialSurface(shape: shape, tint: tint))
        }
        #else
        content.modifier(MaterialSurface(shape: shape, tint: tint))
        #endif
    }
}

private struct GlassIdentity<ID: Hashable & Sendable>: ViewModifier {
    let id: ID
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        #if compiler(>=6.2) && !PINGO_LEGACY_GLASS
        if #available(iOS 26, *) {
            content.glassEffectID(id, in: namespace)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

private struct MaterialSurface<S: Shape>: ViewModifier {
    let shape: S
    let tint: Color?

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    shape.fill(.ultraThinMaterial)
                    if let tint {
                        shape.fill(tint)
                    }
                }
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 6)
            }
            .overlay {
                shape.stroke(Color.white.opacity(0.35), lineWidth: 0.8)
            }
    }
}

#if compiler(>=6.2) && !PINGO_LEGACY_GLASS
@available(iOS 26, *)
private extension Glass {
    static func build(tint: Color?, interactive: Bool) -> Glass {
        var glass = Glass.regular
        if let tint {
            glass = glass.tint(tint)
        }
        if interactive {
            glass = glass.interactive()
        }
        return glass
    }
}
#endif
