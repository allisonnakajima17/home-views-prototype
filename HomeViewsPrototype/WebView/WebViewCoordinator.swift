import WebKit

final class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {
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
        updateTopPadding(for: tab)
        updateBackground(for: tab)
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

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        Task { @MainActor in
            viewModel.nativeScrollOffset = scrollView.contentOffset.y
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
        updateTopPadding(for: viewModel.selectedTab)
        let js = """
        (function() {
            var css = document.createElement('style');
            css.id = '__nativeDarkMode';
            if (document.getElementById('__nativeDarkMode')) return;
            css.textContent = `
                @media (prefers-color-scheme: dark) {
                    html, body, #__next, .feed-container {
                        background-color: #212121 !important;
                    }
                }
            `;
            document.head.appendChild(css);
        })();
        """
        webView.evaluateJavaScript(js)
    }

    func updateBackground(for tab: Tab) {
        guard let webView else { return }
        let apply = tab == .trending
        let js = """
        (function() {
            var css = document.getElementById('__nativeBgOverride');
            if (!css) {
                css = document.createElement('style');
                css.id = '__nativeBgOverride';
                document.head.appendChild(css);
            }
            css.textContent = \(apply) ? '' : '';
            if (\(apply)) {
                // Find all card elements (have border-radius) and mark them + descendants
                var cardEls = new Set();
                document.querySelectorAll('*').forEach(function(el) {
                    var br = parseFloat(window.getComputedStyle(el).borderRadius);
                    if (br > 0) {
                        cardEls.add(el);
                        el.querySelectorAll('*').forEach(function(child) {
                            cardEls.add(child);
                        });
                    }
                });
                var isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                var bg = isDark ? '#212121' : '#ffffff';
                document.querySelectorAll('*').forEach(function(el) {
                    var tag = el.tagName.toLowerCase();
                    if (cardEls.has(el) || tag === 'img' || tag === 'video' || tag === 'picture' || tag === 'svg' || tag === 'canvas') {
                        return;
                    }
                    el.style.setProperty('background-color', bg, 'important');
                    el.style.setProperty('background-image', 'none', 'important');
                });
            }
        })();
        """
        webView.evaluateJavaScript(js)
    }

    func updateTopPadding(for tab: Tab) {
        guard let webView else { return }
        let safeTop = webView.safeAreaInsets.top
        // nav (44) + pills (48) + spacing (8) + Following extras (tiles 80 + carousel ~120)
        let followingExtras: CGFloat = tab == .following ? 220 : 0
        let totalPadding = safeTop + 44 + 48 + 8 + followingExtras
        let js = """
        (function() {
            var css = document.getElementById('__nativeTopPadding');
            if (!css) {
                css = document.createElement('style');
                css.id = '__nativeTopPadding';
                document.head.appendChild(css);
            }
            css.textContent = `
                body {
                    padding-top: \(Int(totalPadding))px !important;
                }
            `;
        })();
        """
        webView.evaluateJavaScript(js)
    }

}
