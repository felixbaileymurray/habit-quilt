import Foundation
import Testing
@testable import HabitQuiltDomain

@Suite("DoodleDocument schema")
struct DoodleSchemaTests {
    @Test("encodes schema keys v, paletteId, paper, ops and round-trips")
    func schemaShapeAndRoundTrip() throws {
        let doc = DoodleDocument(
            paletteId: "riso-2026a",
            paper: .dark,
            ops: [
                .stroke(
                    tool: .pencil,
                    ink: .violet,
                    points: [StrokePoint(x: 1, y: 2, pressure: 0.3, ms: 5)]
                ),
                .fill(ink: .red, seedX: 64, seedY: 128),
            ]
        )
        let data = try doc.encodeJSON()
        let object = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(object["v"] as? Int == 1)
        #expect(object["paletteId"] as? String == "riso-2026a")
        #expect(object["paper"] as? String == "dark")
        let ops = try #require(object["ops"] as? [[String: Any]])
        #expect(ops.count == 2)
        #expect(ops[0]["t"] as? String == "stroke")
        #expect(ops[0]["tool"] as? String == "pencil")
        #expect(ops[0]["ink"] as? String == "violet")
        #expect(ops[1]["t"] as? String == "fill")
        #expect(ops[1]["ink"] as? String == "red")

        let decoded = try DoodleDocument.decodeJSON(from: data)
        #expect(decoded == doc)
    }

    @Test("inks are palette IDs, never hex, in serialized JSON")
    func inksArePaletteIDs() throws {
        let doc = DoodleDocument(ops: [
            .stroke(tool: .pen, ink: .teal, points: [
                StrokePoint(x: 0, y: 0, pressure: 1, ms: 0),
            ]),
        ])
        let json = String(decoding: try doc.encodeJSON(), as: UTF8.self)
        #expect(json.contains("\"ink\":\"teal\""))
        #expect(!json.contains("#"))
        #expect(!json.lowercased().contains("0x"))
    }

    @Test("dot-grid never appears in encoded fixtures")
    func noDotGridInFixtures() throws {
        let fixtures: [DoodleDocument] = [
            DoodleDocument(),
            DoodleDocument(paper: .light, ops: [
                .stroke(tool: .pen, ink: .black, points: [
                    StrokePoint(x: 10, y: 10, pressure: 0.5, ms: 0),
                    StrokePoint(x: 20, y: 30, pressure: 0.6, ms: 10),
                ]),
            ]),
            DoodleDocument(paper: .dark, ops: [
                .fill(ink: .orange, seedX: 512, seedY: 512),
                .stroke(tool: .pencil, ink: .yellow, points: [
                    StrokePoint(x: 100, y: 100, pressure: 0.2, ms: 0),
                ]),
            ]),
        ]

        for fixture in fixtures {
            let data = try fixture.encodeJSON()
            let text = String(decoding: data, as: UTF8.self)
            #expect(!text.lowercased().contains("dotgrid"))
            #expect(!text.lowercased().contains("dot_grid"))
            #expect(!text.lowercased().contains("dot-grid"))
            #expect(!text.lowercased().contains("showdotgrid"))
            #expect(!text.lowercased().contains("gridvisible"))

            let object = try JSONSerialization.jsonObject(with: data)
            #expect(!DoodleDocument.containsForbiddenKeys(object))
        }
    }

    @Test("forbidden-key scanner catches planted dot-grid keys")
    func forbiddenKeyScanner() {
        let planted: [String: Any] = [
            "v": 1,
            "paletteId": "riso-2026a",
            "paper": "light",
            "ops": [] as [Any],
            "dotGrid": true,
        ]
        #expect(DoodleDocument.containsForbiddenKeys(planted))

        let nested: [String: Any] = [
            "v": 1,
            "meta": ["showDotGrid": false] as [String: Any],
        ]
        #expect(DoodleDocument.containsForbiddenKeys(nested))
    }

    @Test("provisional palette has 2 papers and 8 mid-opacity inks")
    func provisionalPalette() {
        let palette = Palette.riso2026a
        #expect(palette.id == "riso-2026a")
        #expect(Set(palette.papers.keys) == Set(PaperID.allCases))
        #expect(Set(palette.inks.keys) == Set(InkID.allCases))
        #expect(PaperID.allCases.count == 2)
        #expect(InkID.allCases.count == 8)
        for ink in InkID.allCases {
            let color = palette.inkColor(ink)!
            #expect(color.a > 0 && color.a < 1.0)
        }
        #expect(Palette.resolve(id: "riso-2026a")?.id == palette.id)
        #expect(Palette.resolve(id: "unknown") == nil)
    }
}
