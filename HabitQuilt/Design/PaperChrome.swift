import SwiftUI

/// Opaque paper chrome — avoids system Liquid Glass on nav bars / toolbars.
struct PaperChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(DesignTokens.PaperUI.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(DesignTokens.PaperUI.background, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
    }
}

extension View {
    func hqPaperChrome() -> some View {
        modifier(PaperChrome())
    }
}
