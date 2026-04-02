import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                SwiftUI.Tab("Home", image: "TabHome") {
                    ContentView(viewModel: viewModel)
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
            .toolbarVisibility(viewModel.pillsVisible ? .visible : .hidden, for: .tabBar)
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}
