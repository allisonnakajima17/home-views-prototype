import SwiftUI
import WebKit

/// Wraps WKWebView in a UIViewControllerRepresentable so we can override
/// contentScrollView(for:) — this tells the UITabBarController which scroll
/// view to observe for the liquid glass minimize/restore animation.
struct WebViewRepresentable: UIViewControllerRepresentable {
    let viewModel: AppViewModel

    func makeCoordinator() -> WebViewCoordinator {
        let coordinator = WebViewCoordinator(viewModel: viewModel)
        viewModel.webCoordinator = coordinator
        return coordinator
    }

    func makeUIViewController(context: Context) -> WebViewController {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "scrollHandler")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.observeScrollView(webView.scrollView)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        context.coordinator.setWebView(webView)

        if let url = URL(string: "https://fauxpamine-ui.dev.cms.cbssports.cloud/?team_ids=21190,409,2911293") {
            webView.load(URLRequest(url: url))
        }

        let vc = WebViewController()
        vc.webView = webView
        return vc
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        // No updates needed — tab switching is handled via coordinator
    }
}

/// A UIViewController that exposes the WKWebView's scroll view via
/// contentScrollView(for:), enabling the tab bar minimize behavior
/// to observe real user scroll gestures.
class WebViewController: UIViewController {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        return webView?.scrollView
    }
}
