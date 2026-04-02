import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    let viewModel: AppViewModel

    func makeCoordinator() -> WebViewCoordinator {
        let coordinator = WebViewCoordinator(viewModel: viewModel)
        viewModel.webCoordinator = coordinator
        return coordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "scrollHandler")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        // Don't set scroll view delegate — the system needs it to detect
        // scroll direction for tab bar minimize/restore.
        // Track nativeScrollOffset via KVO instead.
        context.coordinator.observeScrollView(webView.scrollView)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        context.coordinator.setWebView(webView)

        if let url = URL(string: "https://fauxpamine-ui.dev.cms.cbssports.cloud/?team_ids=21190,409,2911293") {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed — tab switching is handled via coordinator
    }
}
