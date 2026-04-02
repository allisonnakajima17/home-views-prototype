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
            .background(TabBarHider(isHidden: !viewModel.pillsVisible))
            .environment(\.theme, colorScheme == .dark ? .dark : .light)
            .preferredColorScheme(nil)
        }
    }
}

/// Finds the hosting UITabBarController and calls setTabBarHidden(_:animated:)
/// so the tab bar hides/shows in sync with the pills on scroll.
struct TabBarHider: UIViewRepresentable {
    let isHidden: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        view.frame = .zero
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let tabBarController = uiView.findTabBarController() else { return }
            tabBarController.setTabBarHidden(isHidden, animated: true)
        }
    }
}

private extension UIView {
    func findTabBarController() -> UITabBarController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let tabBarController = next as? UITabBarController {
                return tabBarController
            }
            responder = next
        }
        return nil
    }
}
