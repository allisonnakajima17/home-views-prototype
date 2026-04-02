import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme

    var body: some Scene {
        WindowGroup {
            TabView {
                SwiftUI.Tab("Home", image: "TabHome") {
                    ContentView()
                }
                SwiftUI.Tab("Scores", image: "TabScores") {
                    Color.clear
                }
                SwiftUI.Tab("Watch", image: "TabWatch") {
                    Color.clear
                }
                SwiftUI.Tab("Picks", image: "TabPicks") {
                    Color.clear
                }
                SwiftUI.Tab(role: .search) {
                    Color.clear
                }
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}
