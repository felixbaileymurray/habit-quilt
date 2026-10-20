# Habit Quilt UI components

Agents: use these wrappers, `DesignTokens`, and `HQIcon` only. Do not invent ad-hoc colours, fonts, SF Symbols, or one-off button styles in screens.

## Allowed chrome

| Component | Use for |
| --- | --- |
| `HQText` | All body / title / caption text (wraps `Copy` draft strings) |
| `HQButton` | Primary and secondary actions |
| `HQIcon` / `HQIconView` | Vector icons (Lucide placeholders → hand-drawn pack later) |
| `HQIconButton` | Toolbar / compact icon actions |
| `HQIconChip` | Selected tool / tray chips |
| `HQTextField` | Habit name and short text entry |
| `HQToggle` | Boolean settings and session aids (e.g. dot grid) — custom, not system Toggle |
| `HQListRow` | Settings rows |

Apply `.hqPaperChrome()` on screens with a navigation bar so system Liquid Glass does not restyle chrome. Prefer opaque paper backgrounds over materials / `.glassEffect`.

Add a new component **only** when a second screen needs the same pattern.

## Rules

1. Colours and spacing come from `DesignTokens` — never raw hex in views.
2. User-facing strings come from `Copy` via `draft("…")` until a human rewrites them.
3. Light paper UI only — no dark-mode variants.
4. Drawing inks use riso **palette IDs**, not hex, in any persisted data.
5. Dot-grid toggle is session UI only; never store it in doodle JSON.
6. Icons: semantic `HQIcon` only — see `Design/Icons/README.md`.
