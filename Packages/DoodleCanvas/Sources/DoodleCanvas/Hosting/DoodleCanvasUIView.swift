#if os(iOS)
import Metal
import MetalKit
import UIKit

/// Metal-backed live canvas. Strokes are rasterized with Core Graphics and blitted to a texture.
@MainActor
public final class DoodleCanvasUIView: MTKView {
    public let session: DoodleSession
    public var configuration: DoodleCanvasConfiguration {
        didSet { setNeedsDisplay() }
    }

    private var commandQueue: MTLCommandQueue?
    private var displayTexture: MTLTexture?
    private var lastRenderSignature: Int = 0

    public init(session: DoodleSession, configuration: DoodleCanvasConfiguration = .init()) {
        self.session = session
        self.configuration = configuration
        let device = MTLCreateSystemDefaultDevice()
        super.init(frame: .zero, device: device)
        commonInit()
    }

    @available(*, unavailable)
    public required init(coder: NSCoder) {
        fatalError("init(coder:) is unavailable")
    }

    private func commonInit() {
        isPaused = true
        enableSetNeedsDisplay = true
        isMultipleTouchEnabled = false
        clearColor = MTLClearColor(red: 0.97, green: 0.95, blue: 0.90, alpha: 1)
        framebufferOnly = false
        colorPixelFormat = .bgra8Unorm
        if let device {
            commandQueue = device.makeCommandQueue()
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    public func refresh() {
        lastRenderSignature = 0
        setNeedsDisplay()
    }

    public override func draw(_ rect: CGRect) {
        renderIfNeeded()
        guard let drawable = currentDrawable,
              let commandQueue,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let texture = displayTexture
        else {
            return
        }

        guard let blit = commandBuffer.makeBlitCommandEncoder() else { return }
        let width = min(texture.width, drawable.texture.width)
        let height = min(texture.height, drawable.texture.height)
        blit.copy(
            from: texture,
            sourceSlice: 0,
            sourceLevel: 0,
            sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
            sourceSize: MTLSize(width: width, height: height, depth: 1),
            to: drawable.texture,
            destinationSlice: 0,
            destinationLevel: 0,
            destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0)
        )
        blit.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func renderIfNeeded() {
        let signature = renderSignature()
        guard signature != lastRenderSignature || displayTexture == nil else { return }
        lastRenderSignature = signature

        let pixelSize = max(64, Int(max(bounds.width, bounds.height) * contentScaleFactor))
        // BGRA matches MTKView drawable (`.bgra8Unorm`) for a straight blit.
        guard let context = CGStrokeRenderer.makeBitmapContext(size: pixelSize, format: .bgra) else { return }
        context.translateBy(x: 0, y: CGFloat(pixelSize))
        context.scaleBy(x: 1, y: -1)

        var options = CGStrokeRenderer.Options(
            size: pixelSize,
            showsDotGrid: configuration.showsDotGrid
        )
        if session.isStrokeInProgress {
            options.liveStroke = (session.selectedTool, session.selectedInk, session.liveStrokePoints)
        }
        CGStrokeRenderer.draw(session.document, in: context, options: options)
        guard let data = context.data, let device else { return }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: pixelSize,
            height: pixelSize,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead]
        guard let texture = device.makeTexture(descriptor: descriptor) else { return }
        texture.replace(
            region: MTLRegionMake2D(0, 0, pixelSize, pixelSize),
            mipmapLevel: 0,
            withBytes: data,
            bytesPerRow: pixelSize * 4
        )
        displayTexture = texture
    }

    private func renderSignature() -> Int {
        var hasher = Hasher()
        hasher.combine(session.document)
        hasher.combine(configuration.showsDotGrid)
        hasher.combine(session.liveStrokePoints)
        hasher.combine(Int(bounds.width * 10))
        hasher.combine(Int(bounds.height * 10))
        return hasher.finalize()
    }

    private func normalizedPoint(from location: CGPoint) -> DoodlePoint {
        let side = min(bounds.width, bounds.height)
        guard side > 0 else { return DoodlePoint(x: 0, y: 0) }
        let originX = (bounds.width - side) / 2
        let originY = (bounds.height - side) / 2
        let x = Double((location.x - originX) / side) * CanvasSpace.size
        let y = Double((location.y - originY) / side) * CanvasSpace.size
        return DoodlePoint(x: x, y: y, pressure: 0.5, tMs: 0)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard configuration.isInteractive else { return }
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began:
            session.beginStroke(at: normalizedPoint(from: location))
        case .changed:
            session.appendStroke(point: normalizedPoint(from: location))
        case .ended, .cancelled:
            if gesture.state == .cancelled {
                session.cancelStroke()
            } else {
                session.endStroke()
            }
        default:
            break
        }
        setNeedsDisplay()
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard configuration.isInteractive else { return }
        let point = normalizedPoint(from: gesture.location(in: self))
        session.beginStroke(at: point)
        session.endStroke()
        setNeedsDisplay()
    }
}
#endif
