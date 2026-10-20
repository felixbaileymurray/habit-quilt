import SwiftUI

/// Stroked vector icon from the active pack (Lucide placeholders for now).
struct HQIconView: View {
    let icon: HQIcon
    var size: CGFloat = 22
    var color: Color = DesignTokens.PaperUI.textPrimary
    /// Stroke width at the 24pt Lucide viewBox; scales with `size`.
    var strokeWidthAt24: CGFloat = 2

    var body: some View {
        HQIconShape(icon: icon)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: strokeWidthAt24 * size / LucidePlaceholderPaths.viewBox,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

private struct HQIconShape: Shape {
    var icon: HQIcon

    func path(in rect: CGRect) -> Path {
        let source = LucidePlaceholderPaths.path(for: icon)
        let box = LucidePlaceholderPaths.viewBox
        let scale = min(rect.width, rect.height) / box
        let dx = rect.minX + (rect.width - box * scale) / 2
        let dy = rect.minY + (rect.height - box * scale) / 2
        return source.applying(
            CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: dx, ty: dy)
        )
    }
}
