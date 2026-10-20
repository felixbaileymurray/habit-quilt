import SwiftUI

struct HabitSetupView: View {
    @Bindable var store: AppStore
    @State private var name: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.lg) {
            HQText(draft: Copy.habitSetupTitle, style: .title)
            HQText(draft: Copy.habitSetupSubtitle, style: .callout)
                .foregroundStyle(DesignTokens.PaperUI.textSecondary)

            HQTextField(placeholder: Copy.habitSetupPlaceholder, text: $name)

            Spacer()

            HQButton(title: Copy.habitSetupContinue, kind: .primary) {
                store.createHabit(name: name)
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(DesignTokens.Space.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
    }
}
