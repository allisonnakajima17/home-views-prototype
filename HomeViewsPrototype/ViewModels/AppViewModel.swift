import SwiftUI
import UIKit

@Observable
final class AppViewModel {
    var selectedTab: Tab = .forYou
    var selectedTeamScreen: TeamTile?
    var scrollOffset: CGFloat = 0
    var nativeScrollOffset: CGFloat = 0
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
        1.0
    }

    func selectTab(_ tab: Tab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        withAnimation(.easeInOut(duration: 0.35)) { pillsVisible = true }
        UISelectionFeedbackGenerator().selectionChanged()
        webCoordinator?.switchToTab(tab)
    }

    func handleScrollUpdate(offset: CGFloat) {
        scrollOffset = offset

        let delta = offset - prevOffset
        let nearTop = offset < 5

        if nearTop {
            if !pillsVisible {
                withAnimation(.easeInOut(duration: 0.35)) { pillsVisible = true }
            }
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

        // Threshold matches native tab bar minimize timing —
        // low enough to fire in sync with system, with a small
        // buffer to filter scroll noise from the web view
        let threshold: CGFloat = currentDirection == .up ? 6 : 3
        if accumulated > threshold {
            let shouldShow = currentDirection == .up
            if shouldShow != pillsVisible {
                // Native tab bar uses ~0.35s ease; match it so pills and tabs move together
                withAnimation(.easeInOut(duration: 0.35)) { pillsVisible = shouldShow }
            }
        }

        prevOffset = offset
    }
}
