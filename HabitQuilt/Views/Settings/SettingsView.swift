import SwiftUI

struct SettingsView: View {
    @Bindable var store: AppStore
    @State private var editingName: String = ""
    @State private var isEditingHabit = false

    var body: some View {
        List {
            Section {
                HQListRow(
                    title: Copy.settingsHabit,
                    subtitle: store.habit.map { DraftString(raw: $0.name) } ?? Copy.habitSetupPlaceholder
                ) {
                    editingName = store.habit?.name ?? ""
                    isEditingHabit = true
                }
            }

            Section {
                HQListRow(title: Copy.settingsExport, subtitle: Copy.settingsExportSoon)
                HQListRow(title: Copy.settingsImport, subtitle: Copy.settingsImportSoon)
                HQListRow(title: Copy.settingsLastBackup)
            }

            // TODO(M3): wire export/import zip backup.
        }
        .scrollContentBackground(.hidden)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
        .navigationTitle(Copy.settingsTitle.text)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditingHabit) {
            NavigationStack {
                VStack(alignment: .leading, spacing: DesignTokens.Space.md) {
                    HQText(draft: Copy.settingsEditHabit, style: .headline)
                    HQTextField(placeholder: Copy.habitSetupPlaceholder, text: $editingName)
                    HQButton(title: Copy.habitSetupContinue, kind: .primary) {
                        store.renameHabit(name: editingName)
                        isEditingHabit = false
                    }
                    Spacer()
                }
                .padding(DesignTokens.Space.lg)
                .background(DesignTokens.PaperUI.background.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Copy.settingsClose.text) { isEditingHabit = false }
                    }
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
