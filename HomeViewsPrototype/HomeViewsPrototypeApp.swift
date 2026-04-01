import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                Color.clear
                    .tabItem {
                        Label("Scores", systemImage: "sportscourt.fill")
                    }
                Color.clear
                    .tabItem {
                        Label("Watch", systemImage: "play.tv.fill")
                    }
                Color.clear
                    .tabItem {
                        Label("Picks", systemImage: "checkmark.circle.fill")
                    }
                Color.clear
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
            }
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}
