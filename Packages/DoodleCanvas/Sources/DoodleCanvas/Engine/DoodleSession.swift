import Foundation

/// Editable doodle session: tools, palette, undo/redo, clear, live stroke capture.
@MainActor
public final class DoodleSession {
    public private(set) var document: DoodleDocument
    public var selectedTool: DrawingToolID
    public var selectedInk: InkID
    /// Session UI only — never written into `document`.
    public var ui: DoodleSessionUIState

    private var undoStack: [[DoodleOp]] = []
    private var redoStack: [[DoodleOp]] = []
    private var livePoints: [DoodlePoint] = []
    private var strokeStartDate: Date?

    public init(
        document: DoodleDocument = DoodleDocument(),
        selectedTool: DrawingToolID = .pen,
        selectedInk: InkID = .blue,
        ui: DoodleSessionUIState = DoodleSessionUIState()
    ) {
        self.document = document
        self.selectedTool = selectedTool
        self.selectedInk = selectedInk
        self.ui = ui
    }

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    public var isStrokeInProgress: Bool { !livePoints.isEmpty }
    public var liveStrokePoints: [DoodlePoint] { livePoints }

    public func setPaper(_ paper: PaperKind) {
        pushUndoCheckpoint()
        document.paper = paper
        redoStack.removeAll()
    }

    public func beginStroke(at point: DoodlePoint) {
        strokeStartDate = Date()
        livePoints = [CanvasSpace.clamp(point.with(tMs: 0))]
    }

    public func appendStroke(point: DoodlePoint) {
        guard isStrokeInProgress else { return }
        let start = strokeStartDate ?? Date()
        let tMs = Date().timeIntervalSince(start) * 1000
        livePoints.append(CanvasSpace.clamp(point.with(tMs: tMs)))
    }

    @discardableResult
    public func endStroke() -> DoodleOp? {
        guard !livePoints.isEmpty else { return nil }
        let points = livePoints
        livePoints = []
        strokeStartDate = nil
        let op = DoodleOp.stroke(tool: selectedTool, ink: selectedInk, points: points)
        pushUndoCheckpoint()
        document.ops.append(op)
        redoStack.removeAll()
        return op
    }

    public func cancelStroke() {
        livePoints = []
        strokeStartDate = nil
    }

    public func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(document.ops)
        document.ops = previous
        cancelStroke()
    }

    public func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(document.ops)
        document.ops = next
        cancelStroke()
    }

    public func clear() {
        guard !document.ops.isEmpty || isStrokeInProgress else { return }
        pushUndoCheckpoint()
        document.ops = []
        redoStack.removeAll()
        cancelStroke()
    }

    public func replaceDocument(_ document: DoodleDocument) {
        self.document = document
        undoStack.removeAll()
        redoStack.removeAll()
        cancelStroke()
    }

    private func pushUndoCheckpoint() {
        undoStack.append(document.ops)
        // Bound memory for long sessions.
        if undoStack.count > 100 {
            undoStack.removeFirst(undoStack.count - 100)
        }
    }
}

private extension DoodlePoint {
    func with(tMs: Double) -> DoodlePoint {
        DoodlePoint(x: x, y: y, pressure: pressure, tMs: tMs)
    }
}
