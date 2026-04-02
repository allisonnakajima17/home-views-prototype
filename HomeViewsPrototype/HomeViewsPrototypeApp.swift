import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Home", image: "TabHome") {
                    ContentView()
                }
                Tab("Scores", image: "TabScores") {
                    Color.clear
                }
                Tab("Watch", image: "TabWatch") {
                    Color.clear
                }
                Tab("Picks", image: "TabPicks") {
                    Color.clear
                }
                Tab(role: .search) {
                    Color.clear
                }
            }
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}
