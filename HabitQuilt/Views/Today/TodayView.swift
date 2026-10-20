import SwiftUI

struct TodayView: View {
    @Bindable var store: AppStore
    @Binding var path: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.lg) {
            if let habit = store.habit {
                HQText(draft: Copy.todayQuestion(habitName: habit.name), style: .headline)
            }

            if let day = store.todayDay, day.doodleJSON != nil {
                HQText(draft: Copy.todayAlreadyDone, style: .body)
                HQButton(title: Copy.doodleTitle, kind: .primary) {
                    store.beginTodayDoodle()
                    path.append(AppRoute.doodle)
                }
            } else {
                HQButton(title: Copy.todayYes, kind: .primary) {
                    store.beginTodayDoodle()
                    path.append(AppRoute.doodle)
                }
                HQButton(title: Copy.todayNotYet, kind: .secondary) {
                    path.append(AppRoute.notYet)
                }
            }

            Spacer()

            HStack(spacing: DesignTokens.Space.md) {
                HQButton(title: Copy.quiltTitle, kind: .secondary) {
                    path.append(AppRoute.quilt)
                }
                HQIconButton(systemName: "gearshape", accessibilityLabel: Copy.settingsTitle.text) {
                    path.append(AppRoute.settings)
                }
            }
        }
        .padding(DesignTokens.Space.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotYetView: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.md) {
            HQText(draft: Copy.notYetTitle, style: .headline)
            HQText(draft: Copy.notYetBody, style: .body)
            Spacer()
            HQButton(title: Copy.notYetDismiss, kind: .secondary) {
                path.removeLast()
            }
        }
        .padding(DesignTokens.Space.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DesignTokens.PaperUI.background.ignoresSafeArea())
    }
}
