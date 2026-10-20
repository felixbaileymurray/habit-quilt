#if os(iOS)
import SwiftUI

/// SwiftUI host for the Metal + Core Graphics doodle canvas.
public struct DoodleCanvasRepresentable: UIViewRepresentable {
    public var session: DoodleSession
    public var configuration: DoodleCanvasConfiguration

    public init(session: DoodleSession, configuration: DoodleCanvasConfiguration = .init()) {
        self.session = session
        self.configuration = configuration
    }

    public func makeUIView(context: Context) -> DoodleCanvasUIView {
        DoodleCanvasUIView(session: session, configuration: configuration)
    }

    public func updateUIView(_ uiView: DoodleCanvasUIView, context: Context) {
        uiView.configuration = configuration
        uiView.refresh()
    }
}
#endif
