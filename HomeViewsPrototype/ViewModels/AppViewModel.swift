import SwiftUI
import UIKit

@Observable
final class AppViewModel {
    var selectedTab: Tab = .forYou
    var scrollOffset: CGFloat = 0
    var pillsVisible: Bool = true

    // Scroll direction tracking
    private var prevOffset: CGFloat = 0
    private var directionAnchor: CGFloat = 0
    private var lastDirection: ScrollDirection = .none

    private enum ScrollDirection {
        case up, down, none
    }

    // Reference to web view coordinator for tab switching
    weak var webCoordinator: WebViewCoordinator?

    var blurOpacity: CGFloat {
        min(max(scrollOffset / 80, 0), 1)
    }

    func selectTab(_ tab: Tab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        pillsVisible = true
        UISelectionFeedbackGenerator().selectionChanged()
        webCoordinator?.switchToTab(tab)
    }

    func handleScrollUpdate(offset: CGFloat) {
        scrollOffset = offset

        let delta = offset - prevOffset
        let nearTop = offset < 5

        if nearTop {
            if !pillsVisible { pillsVisible = true }
            directionAnchor = offset
            lastDirection = .none
            prevOffset = offset
            return
        }

        let currentDirection: ScrollDirection = delta > 0 ? .down : (delta < 0 ? .up : .none)
        guard currentDirection != .none else {
            prevOffset = offset
            return
        }

        if currentDirection != lastDirection {
            directionAnchor = prevOffset
            lastDirection = currentDirection
        }

        let accumulated = abs(offset - directionAnchor)

        // Small threshold — responsive but avoids jitter
        if accumulated > 8 {
            let shouldShow = currentDirection == .up
            if shouldShow != pillsVisible {
                pillsVisible = shouldShow
            }
        }

        prevOffset = offset
    }
}
