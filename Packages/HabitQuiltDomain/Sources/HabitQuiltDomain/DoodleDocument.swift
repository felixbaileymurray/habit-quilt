import Foundation

/// Line tool kinds for stroke ops.
public enum StrokeTool: String, Hashable, Sendable, Codable, CaseIterable {
    case pen
    case pencil
}

/// A single sample on a stroke: normalized canvas coords, pressure, and elapsed ms.
public struct StrokePoint: Hashable, Sendable, Codable {
    public var x: Double
    public var y: Double
    public var pressure: Double
    public var ms: Double

    public init(x: Double, y: Double, pressure: Double, ms: Double) {
        self.x = x
        self.y = y
        self.pressure = pressure
        self.ms = ms
    }
}

/// Drawing operations stored in the versioned doodle document.
///
/// Dot-grid state is a session UI preference only and **must never** appear here.
public enum DoodleOp: Hashable, Sendable, Codable {
    case stroke(tool: StrokeTool, ink: InkID, points: [StrokePoint])
    case fill(ink: InkID, seedX: Double, seedY: Double)

    private enum CodingKeys: String, CodingKey {
        case t, tool, ink, pts, seed
    }

    private enum OpType: String, Codable {
        case stroke
        case fill
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .stroke(tool, ink, points):
            try container.encode(OpType.stroke, forKey: .t)
            try container.encode(tool, forKey: .tool)
            try container.encode(ink, forKey: .ink)
            // Schema: pts as [[x, y, pressure, ms], ...]
            let rows: [[Double]] = points.map { [$0.x, $0.y, $0.pressure, $0.ms] }
            try container.encode(rows, forKey: .pts)
        case let .fill(ink, seedX, seedY):
            try container.encode(OpType.fill, forKey: .t)
            try container.encode(ink, forKey: .ink)
            try container.encode([seedX, seedY], forKey: .seed)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(OpType.self, forKey: .t)
        switch type {
        case .stroke:
            let tool = try container.decode(StrokeTool.self, forKey: .tool)
            let ink = try container.decode(InkID.self, forKey: .ink)
            let rows = try container.decode([[Double]].self, forKey: .pts)
            let points: [StrokePoint] = try rows.map { row in
                guard row.count >= 4 else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .pts,
                        in: container,
                        debugDescription: "Stroke point must be [x, y, pressure, ms]"
                    )
                }
                return StrokePoint(x: row[0], y: row[1], pressure: row[2], ms: row[3])
            }
            self = .stroke(tool: tool, ink: ink, points: points)
        case .fill:
            let ink = try container.decode(InkID.self, forKey: .ink)
            let seed = try container.decode([Double].self, forKey: .seed)
            guard seed.count >= 2 else {
                throw DecodingError.dataCorruptedError(
                    forKey: .seed,
                    in: container,
                    debugDescription: "Fill seed must be [x, y]"
                )
            }
            self = .fill(ink: ink, seedX: seed[0], seedY: seed[1])
        }
    }
}

/// Versioned portable doodle document (vector source of truth).
///
/// Schema keys match the language-agnostic JSON in the build plan:
/// `v`, `paletteId`, `paper`, `ops`. No UIKit types; no dot-grid field.
public struct DoodleDocument: Hashable, Sendable, Codable {
    public static let currentSchemaVersion = 1
    /// Fixed square canvas in normalized units.
    public static let canvasSize: Double = 1024

    public var v: Int
    public var paletteId: String
    public var paper: PaperID
    public var ops: [DoodleOp]

    public init(
        v: Int = DoodleDocument.currentSchemaVersion,
        paletteId: String = Palette.currentProvisional.id,
        paper: PaperID = .light,
        ops: [DoodleOp] = []
    ) {
        self.v = v
        self.paletteId = paletteId
        self.paper = paper
        self.ops = ops
    }

    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    public static let jsonDecoder: JSONDecoder = {
        JSONDecoder()
    }()

    public func encodeJSON() throws -> Data {
        try Self.jsonEncoder.encode(self)
    }

    public static func decodeJSON(from data: Data) throws -> DoodleDocument {
        try jsonDecoder.decode(DoodleDocument.self, from: data)
    }

    /// Keys that must never appear in a serialized doodle document.
    public static let forbiddenSerializedKeys: Set<String> = [
        "dotGrid",
        "dot_grid",
        "dot-grid",
        "showDotGrid",
        "gridVisible",
        "drawingAid",
    ]

    /// Returns `true` if the JSON object graph contains any forbidden key
    /// (case-insensitive match against `forbiddenSerializedKeys`).
    public static func containsForbiddenKeys(_ jsonObject: Any) -> Bool {
        let forbidden = Set(forbiddenSerializedKeys.map { $0.lowercased() })
        return containsForbiddenKeys(jsonObject, forbidden: forbidden)
    }

    private static func containsForbiddenKeys(_ value: Any, forbidden: Set<String>) -> Bool {
        if let dict = value as? [String: Any] {
            for (key, child) in dict {
                if forbidden.contains(key.lowercased()) { return true }
                if containsForbiddenKeys(child, forbidden: forbidden) { return true }
            }
            return false
        }
        if let array = value as? [Any] {
            return array.contains { containsForbiddenKeys($0, forbidden: forbidden) }
        }
        return false
    }
}
