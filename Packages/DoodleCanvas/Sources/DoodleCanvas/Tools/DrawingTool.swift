import Foundation

/// Fixed tool parameters for v1 (no user brush settings).
public struct DrawingToolSpec: Hashable, Sendable {
    public var id: DrawingToolID
    /// Base width in normalized canvas units.
    public var baseWidth: Double
    /// How strongly pressure scales width (0 = constant).
    public var pressureInfluence: Double
    /// Pencil stub uses a slightly wider, softer stroke for visual distinction later.
    public var isStub: Bool

    public init(id: DrawingToolID, baseWidth: Double, pressureInfluence: Double, isStub: Bool = false) {
        self.id = id
        self.baseWidth = baseWidth
        self.pressureInfluence = pressureInfluence
        self.isStub = isStub
    }

    public static let pen = DrawingToolSpec(
        id: .pen,
        baseWidth: 8,
        pressureInfluence: 0.65
    )

    public static let pencil = DrawingToolSpec(
        id: .pencil,
        baseWidth: 14,
        pressureInfluence: 0.4,
        isStub: true
    )

    public static func spec(for id: DrawingToolID) -> DrawingToolSpec {
        switch id {
        case .pen: return .pen
        case .pencil: return .pencil
        }
    }

    public func width(forPressure pressure: Double) -> Double {
        let p = min(max(pressure, 0), 1)
        return baseWidth * (1 - pressureInfluence + pressureInfluence * (0.35 + 0.65 * p))
    }
}
