# Habit Quilt icons

Semantic icons live in `HQIcon`. Screens and components must use `HQIcon` / `HQIconView` / `HQIconButton` — never SF Symbols or ad-hoc asset names.

## Current pack: Lucide (placeholders)

- Geometry: `LucidePlaceholderPaths.swift` (24×24 stroked paths)
- Source SVGs: `Lucide/*.svg` (ISC, from [lucide.dev](https://lucide.dev))

These stand in until a hand-drawn SVG pack lands.

## Custom hand-drawn pack (later)

1. Drop SVGs into a new folder (e.g. `HandDrawn/`) using the same semantic stems as `HQIcon.lucideFileStem`, or map new filenames in `HQIcon`.
2. Replace `LucidePlaceholderPaths` with a loader/renderer for those SVGs (or regenerated path data).
3. Keep `HQIcon` cases stable so call sites do not change.
