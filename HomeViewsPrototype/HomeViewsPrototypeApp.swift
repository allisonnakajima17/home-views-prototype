import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = AppViewModel()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        if let font = UIFont(name: "TTNormsPro-Bold", size: 17) {
            appearance.titleTextAttributes = [.font: font]
            appearance.largeTitleTextAttributes = [.font: UIFont(name: "TTNormsPro-Bold", size: 34) ?? font]
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

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
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}
