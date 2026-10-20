/// Public surface placeholder for the custom vector doodle canvas.
/// Sibling workers own Skia/Metal (or Metal+CG) implementation.
/// Dot-grid is a session UI aid only — never part of the doodle document.

import Foundation
import SwiftUI

/// Ink identifiers (palette IDs, never raw hex in documents).
public enum RisoInkID: String, Sendable, CaseIterable, Codable {
    case red, orange, yellow, green, blue, violet, brown, black
}

public enum PaperID: String, Sendable, CaseIterable, Codable {
    case light
    case dark
}

public enum DrawingTool: String, Sendable, CaseIterable {
    case pen
    case pencil
    case fill
}

/// Session-only drawing aid. Not persisted in doodle JSON.
public struct DotGridSessionState: Sendable, Equatable {
    public var isVisible: Bool

    public init(isVisible: Bool = false) {
        self.isVisible = isVisible
    }
}

/// Protocol the app hosts until the canvas package ships.
public protocol DoodleCanvasHosting: AnyObject {
    var selectedTool: DrawingTool { get set }
    var selectedInk: RisoInkID { get set }
    var paper: PaperID { get set }
    var dotGrid: DotGridSessionState { get set }

    func undo()
    func redo()
    func clear()
    /// Serialize to portable doodle JSON ops (no dot-grid field).
    func exportDocumentJSON() throws -> Data
}

/// SwiftUI placeholder view until real canvas lands.
public struct DoodleCanvasPlaceholderView: View {
    @Binding public var dotGridVisible: Bool

    public init(dotGridVisible: Binding<Bool>) {
        self._dotGridVisible = dotGridVisible
    }

    public var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.94, blue: 0.90)
            if dotGridVisible {
                Text("Dot grid (session only)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Canvas placeholder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("Doodle canvas placeholder")
    }
}
