import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Home", image: "TabHome")
                    }
                Color.clear
                    .tabItem {
                        Label("Scores", image: "TabScores")
                    }
                Color.clear
                    .tabItem {
                        Label("Watch", image: "TabWatch")
                    }
                Color.clear
                    .tabItem {
                        Label("Picks", image: "TabPicks")
                    }
                Color.clear
                    .tabItem {
                        Label("More", image: "TabMore")
                    }
            }
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}
