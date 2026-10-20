import Foundation

public enum DoodleCodecError: Error, Equatable, Sendable {
    case unsupportedVersion(Int)
    case emptyData
    case decodingFailed(String)
}

/// Encode / decode the language-agnostic doodle JSON schema from the build plan.
public enum DoodleCodec: Sendable {
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    private static let decoder = JSONDecoder()

    public static func encode(_ document: DoodleDocument) throws -> Data {
        try encoder.encode(document)
    }

    public static func encodeString(_ document: DoodleDocument) throws -> String {
        let data = try encode(document)
        guard let string = String(data: data, encoding: .utf8) else {
            throw DoodleCodecError.decodingFailed("UTF-8 encode failed")
        }
        return string
    }

    public static func decode(_ data: Data) throws -> DoodleDocument {
        guard !data.isEmpty else { throw DoodleCodecError.emptyData }
        let document: DoodleDocument
        do {
            document = try decoder.decode(DoodleDocument.self, from: data)
        } catch {
            throw DoodleCodecError.decodingFailed(String(describing: error))
        }
        guard document.v == DoodleDocument.currentVersion else {
            throw DoodleCodecError.unsupportedVersion(document.v)
        }
        return document
    }

    public static func decode(json: String) throws -> DoodleDocument {
        guard let data = json.data(using: .utf8) else {
            throw DoodleCodecError.decodingFailed("Invalid UTF-8")
        }
        return try decode(data)
    }

    /// True when serialized JSON contains no dot-grid keys (aid is session-only).
    public static func serializedJSONOmitsDotGrid(_ data: Data) -> Bool {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        let forbidden = ["dotGrid", "dot_grid", "showsDotGrid", "grid"]
        return forbidden.allSatisfy { object[$0] == nil }
    }
}
