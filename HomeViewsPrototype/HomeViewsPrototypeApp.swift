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
                        .background(TabBarRestorer(pillsVisible: viewModel.pillsVisible))
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

/// On scroll-up (pillsVisible = true), forces the tab bar to restore via
/// setTabBarHidden(false). The liquid glass minimize on scroll-down is
/// handled natively by .tabBarMinimizeBehavior(.onScrollDown).
struct TabBarRestorer: UIViewRepresentable {
    let pillsVisible: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        view.frame = .zero
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Only act on restore — let the system handle minimize
        guard pillsVisible else { return }
        DispatchQueue.main.async {
            guard let tabBarController = uiView.findTabBarController() else { return }
            if tabBarController.isTabBarHidden {
                tabBarController.setTabBarHidden(false, animated: true)
            }
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
