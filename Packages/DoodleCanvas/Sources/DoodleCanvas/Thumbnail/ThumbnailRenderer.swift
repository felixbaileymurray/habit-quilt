import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(ImageIO)
import ImageIO
#endif

public enum ThumbnailRendererError: Error, Equatable, Sendable {
    case graphicsUnavailable
    case renderFailed
    case encodeFailed
}

/// Renders quilt-tile PNG data from a doodle document.
/// Dot-grid is never drawn in thumbnails (drawing aid only).
public enum ThumbnailRenderer: Sendable {
    public static let defaultPixelSize = 256

    /// PNG bytes suitable for caching under Application Support / Documents.
    public static func pngData(
        from document: DoodleDocument,
        pixelSize: Int = defaultPixelSize
    ) throws -> Data {
#if canImport(CoreGraphics) && canImport(ImageIO)
        guard let image = CGStrokeRenderer.makeImage(document, size: pixelSize, showsDotGrid: false) else {
            throw ThumbnailRendererError.renderFailed
        }
        return try encodePNG(image)
#else
        throw ThumbnailRendererError.graphicsUnavailable
#endif
    }

#if canImport(CoreGraphics) && canImport(ImageIO)
    private static func encodePNG(_ image: CGImage) throws -> Data {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            "public.png" as CFString,
            1,
            nil
        ) else {
            throw ThumbnailRendererError.encodeFailed
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ThumbnailRendererError.encodeFailed
        }
        return data as Data
    }
#endif
}
