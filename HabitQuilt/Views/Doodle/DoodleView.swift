import SwiftUI
import DoodleCanvas

/// Doodle screen — hosts real `DoodleSession` + `DoodleCanvasRepresentable`.
struct DoodleView: View {
    @Bindable var store: AppStore
    @Binding var path: NavigationPath

    @State private var session = DoodleSession()
    /// Session-only toggle — never written into doodle JSON.
    @State private var dotGridVisible = false
    @State private var selectedTool: DrawingToolID = .pen
    @State private var selectedInk: InkID = .blue
    /// Bumps SwiftUI updates so the UIViewRepresentable refreshes after undo/redo/clear.
    @State private var canvasEpoch = 0

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

            toolTray
                .disabled(!isEditable)

            inkTray
                .disabled(!isEditable)

#if os(iOS)
            // Read epoch so undo/redo/clear invalidate the representable.
            let _ = canvasEpoch
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
#else
            Color(DesignTokens.DrawingPaper.light.color)
                .aspectRatio(1, contentMode: .fit)
#endif

            // UI-only drawing aid; not persisted in doodle documents.
            HQToggle(title: Copy.doodleDotGrid, isOn: $dotGridVisible)
                .disabled(!isEditable)
                .onChange(of: dotGridVisible) { _, visible in
                    session.ui.showsDotGrid = visible
                }

            editActions
                .disabled(!isEditable)

            Spacer(minLength: 0)

            HQButton(title: Copy.doodleDone, kind: .primary) {
                saveAndFinish()
            }
            .disabled(!isEditable)
        }
        .padding(DesignTokens.Space.lg)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
        .navigationTitle(Copy.doodleTitle.text)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.beginTodayDoodle()
            dotGridVisible = store.doodleDotGridVisible
            session.ui.showsDotGrid = dotGridVisible
            session.selectedTool = selectedTool
            session.selectedInk = selectedInk
            loadExistingDocumentIfAny()
        }
        .onChange(of: selectedTool) { _, tool in
            session.selectedTool = tool
        }
        .onChange(of: selectedInk) { _, ink in
            session.selectedInk = ink
        }
    }

    private var toolTray: some View {
        HStack(spacing: DesignTokens.Space.sm) {
            ForEach(DrawingToolID.allCases, id: \.self) { tool in
                Button {
                    selectedTool = tool
                } label: {
                    Text(toolLabel(tool).text)
                        .font(DesignTokens.TypeScale.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Space.sm)
                        .padding(.vertical, DesignTokens.Space.xs)
                        .background(
                            selectedTool == tool
                                ? DesignTokens.PaperUI.accent.opacity(0.2)
                                : DesignTokens.PaperUI.surface
                        )
                        .foregroundStyle(DesignTokens.PaperUI.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                                .stroke(
                                    selectedTool == tool
                                        ? DesignTokens.PaperUI.accent
                                        : DesignTokens.PaperUI.border,
                                    lineWidth: 1
                                )
                        )
                        .draftHighlight()
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    private var inkTray: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Space.xs) {
                ForEach(InkID.allCases, id: \.self) { ink in
                    Button {
                        selectedInk = ink
                    } label: {
                        Circle()
                            .fill(inkSwiftUIColor(ink))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedInk == ink
                                            ? DesignTokens.PaperUI.textPrimary
                                            : DesignTokens.PaperUI.border,
                                        lineWidth: selectedInk == ink ? 2 : 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ink.rawValue)
                }
            }
        }
    }

    private var editActions: some View {
        HStack(spacing: DesignTokens.Space.sm) {
            HQButton(title: Copy.doodleUndo, kind: .secondary) {
                session.undo()
                canvasEpoch += 1
            }
            .disabled(!session.canUndo)
            HQButton(title: Copy.doodleRedo, kind: .secondary) {
                session.redo()
                canvasEpoch += 1
            }
            .disabled(!session.canRedo)
            HQButton(title: Copy.doodleClear, kind: .secondary) {
                session.clear()
                canvasEpoch += 1
            }
        }
    }

    private func toolLabel(_ tool: DrawingToolID) -> DraftString {
        switch tool {
        case .pen: Copy.doodleToolPen
        case .pencil: Copy.doodleToolPencil
        }
    }

    private func inkSwiftUIColor(_ ink: InkID) -> Color {
        let rgba = RisoPalette.color(for: ink)
        return Color(.sRGB, red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
    }

    private func loadExistingDocumentIfAny() {
        guard let json = store.todayDay?.doodleJSON,
              let document = try? DoodleCodec.decode(json: json)
        else { return }
        session.replaceDocument(document)
    }

    private func saveAndFinish() {
        do {
            let data = try DoodleCodec.encode(session.document)
            assert(DoodleCodec.serializedJSONOmitsDotGrid(data))
            let json = try DoodleCodec.encodeString(session.document)
            let thumb = try? ThumbnailRenderer.pngData(from: session.document)
            store.saveDoodle(json: json, thumbnailPNG: thumb)
            store.setDotGridDefault(dotGridVisible)
            store.endDoodleSession()
            path.append(AppRoute.quilt)
        } catch {
            assertionFailure("doodle save failed: \(error)")
        }
    }
}
