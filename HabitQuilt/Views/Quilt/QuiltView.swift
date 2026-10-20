import SwiftUI
import HabitQuiltDomain

/// Quilt placeholder shell. Full grid UI is later; layout snaps come from HabitQuiltDomain.
struct QuiltView: View {
    @Bindable var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.md) {
            HQText(draft: Copy.quiltTitle, style: .headline)

            HQToggle(title: Copy.quiltHideBlanks, isOn: Binding(
                get: { store.hideBlankDays },
                set: { store.setHideBlankDays($0) }
            ))

            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(DesignTokens.PaperUI.surface)
                .overlay {
                    VStack(spacing: DesignTokens.Space.sm) {
                        HQText(draft: Copy.quiltEmpty, style: .body)
                        HQText(draft: Copy.quiltPlaceholder, style: .caption)
                            .foregroundStyle(DesignTokens.PaperUI.textSecondary)
                        Text(
                            "Columns: "
                                + QuiltColumnCount.snaps.map { String($0.rawValue) }.joined(separator: ", ")
                        )
                        .font(DesignTokens.TypeScale.caption)
                        .foregroundStyle(DesignTokens.PaperUI.textSecondary)
                    }
                    .padding(DesignTokens.Space.md)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // TODO: LazyVGrid / Metal quilt of thumbnails using QuiltLayout.tiles(...)
        }
        .padding(DesignTokens.Space.lg)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
        .navigationTitle(Copy.quiltTitle.text)
        .navigationBarTitleDisplayMode(.inline)
    }
}
