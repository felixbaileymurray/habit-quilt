# Habit Quilt

iOS proof-of-concept: one habit, one doodle a day, quilt over time.

**Stack:** SwiftUI, custom vector canvas (not PencilKit), SQLite, local-only.

## Open in Xcode

1. Open `HabitQuilt.xcodeproj` on a Mac.
2. Select an iPhone simulator or device.
3. Run the `HabitQuilt` scheme.

Feel / drawing / quilt UX must be judged on a real Mac + iPhone. Cloud agents do not run the Simulator or TestFlight.

## Layout

| Path | Role |
| --- | --- |
| `HabitQuilt/` | App target — navigation, screens, tokens, copy, SQLite repo |
| `HabitQuiltTests/` | Pure logic unit tests (day preserve, midnight, repository) |
| `Packages/HabitQuiltDomain/` | Domain package (sibling-owned; stub APIs for SPM) |
| `Packages/DoodleCanvas/` | Canvas package (sibling-owned; stub APIs for SPM) |
| `.github/workflows/ios.yml` | PR → `dev`: `xcodebuild` build + unit tests on `macos-latest` |

## Git

- `main` — production
- `dev` — integration
- Feature branches off `dev`; PRs target `dev`
