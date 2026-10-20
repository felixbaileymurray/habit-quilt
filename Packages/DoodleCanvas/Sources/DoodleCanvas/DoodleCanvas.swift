/// Habit Quilt doodle canvas — custom vector engine (Metal + Core Graphics).
///
/// Not PencilKit. Document format matches the build-plan doodle JSON schema.
///
/// Primary exports for the app:
/// - ``DoodleDocument`` / ``DoodleCodec``
/// - ``DoodleSession``
/// - ``RisoPalette`` / ``InkID`` / ``PaperKind``
/// - ``ThumbnailRenderer``
/// - ``DoodleCanvasRepresentable`` (iOS)
public enum DoodleCanvasModuleInfo {
    public static let engineName = "Metal+CoreGraphics"
    public static let engineRationale = """
    Skia C++/Metal deferred: integration/build cost would block this first mergeable PR. \
    Same versioned JSON ops model; CG replay + Metal blit for live canvas.
    """
}
