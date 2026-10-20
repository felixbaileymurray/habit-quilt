import SwiftUI

enum AppRoute: Hashable {
    case notYet
    case doodle
    case quilt
    case settings
}

struct RootNavigation: View {
    @Bindable var store: AppStore
    @State private var path = NavigationPath()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.needsHabitSetup {
                HabitSetupView(store: store)
            } else {
                NavigationStack(path: $path) {
                    TodayView(store: store, path: $path)
                        .navigationDestination(for: AppRoute.self) { route in
                            switch route {
                            case .notYet:
                                NotYetView(path: $path)
                            case .doodle:
                                DoodleView(store: store, path: $path)
                            case .quilt:
                                QuiltView(store: store)
                            case .settings:
                                SettingsView(store: store)
                            }
                        }
                }
            }
        }
        .preferredColorScheme(.light)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                store.tickCalendarBoundary()
            }
        }
        .onAppear {
            store.tickCalendarBoundary()
        }
    }
}
