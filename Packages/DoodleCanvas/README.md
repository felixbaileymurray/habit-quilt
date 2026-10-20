# DoodleCanvas

Swift package for Habit Quilt’s custom vector doodle canvas (M0 S1 / M1 doodle v1).

## Engine choice

**Metal + Core Graphics (Swift)** — the plan’s runner-up path.

Skia C++/Metal was deferred for this first mergeable slice: vendoring/building Skia would dominate S1 cost on the current toolchain (Linux cloud agents cannot link Skia/Metal; macOS CI would need a Skia build pipeline). The same versioned doodle JSON ops model ships now so a later Skia swap can keep the document format.

| Layer | Implementation |
| --- | --- |
| Live canvas | `MTKView` + CG stroke rasterization uploaded to a Metal texture |
| Thumbnails / replay | Pure Core Graphics `CGContext` (no PencilKit, no UI window) |
| Document | Versioned JSON ops (`v`, `paletteId`, `paper`, `ops`) |

## Public API (app-facing)

| Symbol | Role |
| --- | --- |
| `DoodleDocument` | Versioned vector document (paper + ops) |
| `DoodleCodec` | Encode / decode portable JSON |
| `RisoPalette` / `InkID` / `PaperKind` | Curated 8 inks + 2 papers (IDs in JSON, never raw hex) |
| `DoodleSession` | Pen (+ pencil stub), palette selection, undo/redo, clear, live stroke |
| `DoodleCanvasRepresentable` | SwiftUI `UIViewRepresentable` host |
| `DoodleCanvasConfiguration` | Dot-grid toggle (session UI only; not persisted) |
| `ThumbnailRenderer` | PNG Data from a document for quilt tiles |

Dot-grid is a drawing aid only and is **never** serialized into doodle JSON.

## Verification

- Unit / render tests: `swift test` on a Mac (no Simulator required).
- Stroke feel / Pencil latency: owner-side on device later — not exercised in this package’s CI path.
- Linux cloud agents cannot compile Swift/Metal; treat macOS CI / local Xcode as the compile gate.

## Out of scope here

- Fill tool (S1b)
- App Xcode project wiring
- HabitQuiltDomain / SQLite persistence
