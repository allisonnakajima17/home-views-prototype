import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var proxyPosition = ScrollPosition(edge: .top)

    // Header height: nav (44) + pills (48) + spacing (8) = 100
    private let headerHeight: CGFloat = 100

    var body: some View {
        ZStack(alignment: .top) {
            // Ghost ScrollView — mirrors WKWebView offset so the system
            // can detect scroll direction for tab bar minimize/restore.
            ScrollView {
                Color.clear.frame(height: 10000)
            }
            .scrollPosition($proxyPosition)
            .allowsHitTesting(false)
            .opacity(0.01)
            .onChange(of: viewModel.scrollOffset) { _, newOffset in
                proxyPosition = ScrollPosition(point: CGPoint(x: 0, y: newOffset))
            }

            (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                .ignoresSafeArea()

            WebViewRepresentable(viewModel: viewModel)
                .ignoresSafeArea()

            // Following tab overlay — tiles + SAAG carousel
            if viewModel.selectedTab == .following {
                VStack(spacing: 0) {
                    TeamTilesRow(viewModel: viewModel)
                    SAAGCarousel(cardStyle: .subtleStroke)
                    GeometryReader { geo in
                        Image("FollowingFeedPlaceholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width)
                            .clipped()
                    }
                    .allowsHitTesting(false)
                }
                .offset(y: headerHeight - viewModel.nativeScrollOffset)
            }

            // Trending tab placeholder feed (temporarily disabled)
            // if viewModel.selectedTab == .trending {
            //     GeometryReader { geo in
            //         let w = geo.size.width
            //         (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
            //             .ignoresSafeArea()
            //         Image("TrendingFeedPlaceholder")
            //             .resizable()
            //             .scaledToFill()
            //             .frame(width: w)
            //             .clipped()
            //             .offset(y: headerHeight - viewModel.nativeScrollOffset)
            //     }
            //     .allowsHitTesting(false)
            // }

            HeaderView(viewModel: viewModel)

        }
        .overlay {
            // Full-screen team screen — slides from right
            if let tile = viewModel.selectedTeamScreen, let screenImage = tile.screenImage {
                TeamScreenView(imageName: screenImage) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.selectedTeamScreen = nil
                    }
                }
                .ignoresSafeArea()
                .transition(.move(edge: .trailing))
            }
        }
    }
}
