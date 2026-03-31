import SwiftUI

@main
struct HomeViewsPrototypeApp: App {
    @Environment(\.colorScheme) private var colorScheme

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.theme, colorScheme == .dark ? .dark : .light)
                .preferredColorScheme(nil)
        }
    }
}
