import Foundation
import SwiftUI

/// All user-facing strings live here. A human writes final copy.
/// Agents may only add `draft("…")` placeholders — never polish inline in views.
enum Copy {
    // MARK: - Draft marker

    /// Wrap unfinished copy. DEBUG builds highlight draft strings in the UI.
    static func draft(_ text: String) -> DraftString {
        DraftString(raw: text)
    }

    // MARK: - Habit setup

    static let habitSetupTitle = draft("Name your habit")
    static let habitSetupSubtitle = draft("One habit. One doodle a day.")
    static let habitSetupPlaceholder = draft("e.g. stretch for five minutes")
    static let habitSetupContinue = draft("Continue")

    // MARK: - Today

    static func todayQuestion(habitName: String) -> DraftString {
        draft("Did you \(habitName)?")
    }

    static let todayYes = draft("Yes")
    static let todayNotYet = draft("Not yet")
    static let todayAlreadyDone = draft("Today's doodle is ready. Tap to edit until end of day.")
    static let todayPreservedNote = draft("Yesterday's doodle is preserved.")

    // MARK: - Not yet

    static let notYetTitle = draft("No rush")
    static let notYetBody = draft("Come back when you've done it. The day isn't a miss until it's over.")
    static let notYetDismiss = draft("Back")

    // MARK: - Doodle

    static let doodleTitle = draft("Doodle")
    static let doodleDone = draft("Done")
    static let doodleDotGrid = draft("Dot grid")
    static let doodlePlaceholder = draft("Drawing canvas arrives with DoodleCanvas package.")
    static let doodlePreservedBanner = draft("This doodle is preserved.")

    // MARK: - Quilt

    static let quiltTitle = draft("Your quilt")
    static let quiltEmpty = draft("Your quilt will grow here.")
    static let quiltHideBlanks = draft("Hide blank days")
    static let quiltPlaceholder = draft("Quilt grid arrives with HabitQuiltDomain layout.")

    // MARK: - Settings

    static let settingsTitle = draft("Settings")
    static let settingsHabit = draft("Habit")
    static let settingsEditHabit = draft("Edit habit name")
    static let settingsExport = draft("Export backup")
    static let settingsImport = draft("Import backup")
    static let settingsExportSoon = draft("Backup export lands in M3.")
    static let settingsImportSoon = draft("Backup import lands in M3.")
    static let settingsLastBackup = draft("Last backup: never")
    static let settingsClose = draft("Close")
}

/// Placeholder string type so views stay free of raw literals.
struct DraftString: Equatable {
    let raw: String

    var text: String { raw }
}

extension Text {
    /// Renders draft copy; in DEBUG, applies a highlighter background.
    init(_ draft: DraftString) {
        #if DEBUG
        self = Text(draft.text)
        #else
        self = Text(draft.text)
        #endif
    }
}

extension View {
    /// Visual marker for unfinished copy in DEBUG builds.
    @ViewBuilder
    func draftHighlight(_ isDraft: Bool = true) -> some View {
        #if DEBUG
        if isDraft {
            self.background(DesignTokens.PaperUI.draftHighlight)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
