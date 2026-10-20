import Foundation

/// Drawing tool identifiers persisted in doodle JSON.
public enum DrawingToolID: String, Codable, Hashable, Sendable, CaseIterable {
    case pen
    /// Stubbed for v1 — same path encoding as pen with distinct width/texture later.
    case pencil
}

/// One undoable operation in the doodle document.
public enum DoodleOp: Codable, Hashable, Sendable {
    case stroke(tool: DrawingToolID, ink: InkID, points: [DoodlePoint])
    /// Reserved for S1b fill; encoded so older clients can round-trip unknown ops safely via codec versioning.
    case fill(ink: InkID, seedX: Double, seedY: Double)

    private enum CodingKeys: String, CodingKey {
        case t, tool, ink, pts, seed
    }

    private enum OpType: String, Codable {
        case stroke
        case fill
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(OpType.self, forKey: .t)
        switch type {
        case .stroke:
            let tool = try container.decode(DrawingToolID.self, forKey: .tool)
            let ink = try container.decode(InkID.self, forKey: .ink)
            let points = try container.decode([DoodlePoint].self, forKey: .pts)
            self = .stroke(tool: tool, ink: ink, points: points)
        case .fill:
            let ink = try container.decode(InkID.self, forKey: .ink)
            let seed = try container.decode([Double].self, forKey: .seed)
            guard seed.count >= 2 else {
                throw DecodingError.dataCorruptedError(
                    forKey: .seed,
                    in: container,
                    debugDescription: "fill seed requires [x, y]"
                )
            }
            self = .fill(ink: ink, seedX: seed[0], seedY: seed[1])
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .stroke(tool, ink, points):
            try container.encode(OpType.stroke, forKey: .t)
            try container.encode(tool, forKey: .tool)
            try container.encode(ink, forKey: .ink)
            try container.encode(points, forKey: .pts)
        case let .fill(ink, seedX, seedY):
            try container.encode(OpType.fill, forKey: .t)
            try container.encode(ink, forKey: .ink)
            try container.encode([seedX, seedY], forKey: .seed)
        }
    }
}
