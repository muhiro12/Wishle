import SwiftUI

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.25))
            )
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 16) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}
