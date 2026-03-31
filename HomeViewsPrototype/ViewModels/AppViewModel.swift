import SwiftUI
import UIKit

@Observable
final class AppViewModel {
    var selectedTab: Tab = .forYou
    var scrollOffset: CGFloat = 0

    /// 0 = pills fully hidden, 1 = pills fully visible
    /// Driven directly by scroll position for organic feel
    var pillsProgress: CGFloat = 1.0

    // Scroll-driven pills tracking
    private var prevOffset: CGFloat = 0
    private var hideAnchor: CGFloat = 0
    private var isTracking: Bool = false
    private var lastDirection: ScrollDirection = .none

    private let pillsHeight: CGFloat = 52

    private enum ScrollDirection {
        case up, down, none
    }

    // Reference to web view coordinator for tab switching
    weak var webCoordinator: WebViewCoordinator?

    var blurOpacity: CGFloat {
        min(max(scrollOffset / 80, 0), 1)
    }

    var pillsVisible: Bool {
        pillsProgress > 0.5
    }

    func selectTab(_ tab: Tab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        pillsProgress = 1.0
        UISelectionFeedbackGenerator().selectionChanged()
        webCoordinator?.switchToTab(tab)
    }

    func handleScrollUpdate(offset: CGFloat) {
        scrollOffset = offset

        let delta = offset - prevOffset
        let nearTop = offset < 10

        // Always fully show near top
        if nearTop {
            pillsProgress = 1.0
            hideAnchor = offset
            lastDirection = .none
            prevOffset = offset
            return
        }

        let currentDirection: ScrollDirection = delta > 0 ? .down : (delta < 0 ? .up : .none)

        // When direction changes, reset the anchor
        if currentDirection != lastDirection && currentDirection != .none {
            hideAnchor = prevOffset
            lastDirection = currentDirection
        }

        let travel = offset - hideAnchor

        if currentDirection == .down {
            // Scrolling down: collapse pills proportionally over pillsHeight distance
            let progress = 1.0 - min(max(travel / pillsHeight, 0), 1)
            pillsProgress = progress
        } else if currentDirection == .up {
            // Scrolling up: expand pills proportionally over pillsHeight distance
            let progress = min(max(-travel / pillsHeight, 0), 1)
            pillsProgress = max(progress, pillsProgress)
        }

        // Snap to fully shown/hidden when close
        if pillsProgress < 0.05 {
            pillsProgress = 0
        } else if pillsProgress > 0.95 {
            pillsProgress = 1
        }

        prevOffset = offset
    }
}
