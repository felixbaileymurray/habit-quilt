import SwiftUI

@main
struct HabitQuiltApp: App {
    @State private var store = AppEnvironment.makeStore()

    var body: some Scene {
        WindowGroup {
            RootNavigation(store: store)
                .preferredColorScheme(.light)
        }
    }
}
