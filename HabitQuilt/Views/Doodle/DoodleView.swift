import SwiftUI
import DoodleCanvas

/// Doodle screen. Hosts `DoodleCanvasRepresentable`; persistence stays in the app store.
struct DoodleView: View {
    @Bindable var store: AppStore
    @Binding var path: NavigationPath

    /// Session-only toggle — never written into doodle JSON.
    @State private var dotGridVisible = false
    @State private var session = DoodleSession()

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

            DoodleCanvasRepresentable(
                session: session,
                configuration: DoodleCanvasConfiguration(
                    showsDotGrid: dotGridVisible,
                    isInteractive: isEditable
                )
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(DesignTokens.PaperUI.border, lineWidth: 1)
            )
            .allowsHitTesting(isEditable)

            // UI-only drawing aid; not persisted in doodle documents.
            HQToggle(title: Copy.doodleDotGrid, isOn: $dotGridVisible)
                .disabled(!isEditable)
                .onChange(of: dotGridVisible) { _, visible in
                    session.ui.showsDotGrid = visible
                }

            Spacer()

            HQButton(title: Copy.doodleDone, kind: .primary) {
                // Persist canvas document JSON (no dot-grid field).
                if let json = try? DoodleCodec.encodeString(session.document) {
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
            session.ui.showsDotGrid = dotGridVisible
            store.beginTodayDoodle()
            if let json = store.todayDay?.doodleJSON,
               let document = try? DoodleCodec.decode(json: json) {
                session.replaceDocument(document)
            }
        }
    }
}
