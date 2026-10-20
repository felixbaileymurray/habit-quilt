import SwiftUI
import DoodleCanvas
import HabitQuiltDomain

/// Doodle screen shell. Real strokes live in `DoodleCanvas` (sibling package).
struct DoodleView: View {
    @Bindable var store: AppStore
    @Binding var path: NavigationPath

    /// Session-only toggle — never written into doodle JSON.
    @State private var dotGridVisible = false

    private var isEditable: Bool {
        guard let day = store.todayDay else { return true }
        return store.todayDateString == day.date && day.preservedAt == nil
    }

    var body: some View {
        VStack(spacing: DesignTokens.Space.md) {
            if !isEditable {
                HQText(draft: Copy.doodlePreservedBanner, style: .caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            DoodleCanvasPlaceholderView(dotGridVisible: $dotGridVisible)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .stroke(DesignTokens.PaperUI.border, lineWidth: 1)
                )
                .disabled(!isEditable)

            // UI-only drawing aid; not persisted in doodle documents.
            HQToggle(title: Copy.doodleDotGrid, isOn: $dotGridVisible)
                .disabled(!isEditable)

            HQText(draft: Copy.doodlePlaceholder, style: .caption)
                .foregroundStyle(DesignTokens.PaperUI.textSecondary)

            Spacer()

            HQButton(title: Copy.doodleDone, kind: .primary) {
                // TODO(canvas): export real document from DoodleCanvasHosting.
                let stub = DoodleDocument(paper: "light", ops: [])
                if let data = try? JSONEncoder().encode(stub),
                   let json = String(data: data, encoding: .utf8) {
                    store.saveDoodleJSON(json)
                }
                store.endDoodleSession()
                path.append(AppRoute.quilt)
            }
            .disabled(!isEditable)
        }
        .padding(DesignTokens.Space.lg)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
        .navigationTitle(Copy.doodleTitle.text)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            dotGridVisible = store.doodleDotGridVisible
            store.beginTodayDoodle()
        }
        .onDisappear {
            // Keep session open only while on doodle; midnight coordinator uses openDoodleSessionDay.
        }
    }
}
