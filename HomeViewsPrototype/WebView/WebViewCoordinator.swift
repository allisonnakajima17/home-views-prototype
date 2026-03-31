import WebKit

final class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    private let viewModel: AppViewModel
    private weak var webView: WKWebView?

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    // MARK: - Tab Switching

    func switchToTab(_ tab: Tab) {
        let js = """
        (function() {
            var labels = ['for you', 'following', 'trending'];
            var target = labels[\(tab.rawValue)];
            // Search all clickable elements for matching text
            var candidates = document.querySelectorAll('a, button, [role="tab"], [data-tab], span, div[onclick], li');
            for (var i = 0; i < candidates.length; i++) {
                var el = candidates[i];
                var text = el.textContent.trim().toLowerCase();
                if (text === target) {
                    // Temporarily make visible if hidden, click, then re-hide
                    var wasHidden = el.closest('[style*="display: none"]');
                    if (wasHidden) wasHidden.style.display = '';
                    el.click();
                    if (wasHidden) wasHidden.style.display = 'none';
                    return true;
                }
            }
            return false;
        })();
        """
        webView?.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("[TabBridge] Error: \\(error.localizedDescription)")
            }
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "scrollHandler",
              let body = message.body as? [String: Any],
              let offset = body["offset"] as? CGFloat
        else { return }

        Task { @MainActor in
            viewModel.handleScrollUpdate(offset: offset)
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            let credential = URLCredential(user: "faux", password: "daylight", persistence: .forSession)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        injectScrollObserver(into: webView)
        injectTabBarHider(into: webView)
        injectTopPadding(into: webView)
    }

    // MARK: - JS Injection

    private func injectScrollObserver(into webView: WKWebView) {
        let js = """
        (function() {
            if (window.__scrollObserverInstalled) return;
            window.__scrollObserverInstalled = true;

            var ticking = false;

            function findScrollContainer() {
                var candidates = document.querySelectorAll('[style*="overflow"]');
                for (var i = 0; i < candidates.length; i++) {
                    var style = window.getComputedStyle(candidates[i]);
                    if (style.overflowY === 'auto' || style.overflowY === 'scroll') {
                        if (candidates[i].scrollHeight > candidates[i].clientHeight) {
                            return candidates[i];
                        }
                    }
                }
                return document.scrollingElement || document.documentElement;
            }

            var container = findScrollContainer();

            function onScroll() {
                if (!ticking) {
                    requestAnimationFrame(function() {
                        var offset = container.scrollTop || 0;
                        window.webkit.messageHandlers.scrollHandler.postMessage({
                            offset: offset
                        });
                        ticking = false;
                    });
                    ticking = true;
                }
            }

            container.addEventListener('scroll', onScroll, { passive: true });
            window.addEventListener('scroll', onScroll, { passive: true });
        })();
        """
        webView.evaluateJavaScript(js)
    }

    private func injectTabBarHider(into webView: WKWebView) {
        // Hide the web UI's tab bar, header, and debug request bar
        let js = """
        (function() {
            var css = document.createElement('style');
            css.textContent = `
                details,
                nav:first-of-type,
                [role="tablist"],
                header nav,
                header[class*="menubar"],
                header[class*="menuBar"],
                [class*="menubar"],
                [class*="menuBar"] {
                    display: none !important;
                }
            `;
            document.head.appendChild(css);
        })();
        """
        webView.evaluateJavaScript(js)
    }

    private func injectTopPadding(into webView: WKWebView) {
        // Calculate real top padding: safe area + nav (44) + pills (48) + spacing (8)
        let safeTop = webView.safeAreaInsets.top
        let totalPadding = safeTop + 44 + 48 + 8
        let js = """
        (function() {
            var css = document.createElement('style');
            css.id = '__nativeTopPadding';
            if (document.getElementById('__nativeTopPadding')) {
                document.getElementById('__nativeTopPadding').remove();
            }
            css.textContent = `
                body {
                    padding-top: \(Int(totalPadding))px !important;
                }
            `;
            document.head.appendChild(css);
        })();
        """
        webView.evaluateJavaScript(js)
    }

}
