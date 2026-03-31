import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    // Header height: nav (44) + pills (48) + spacing (8) = 100
    private let headerHeight: CGFloat = 100

    var body: some View {
        ZStack(alignment: .top) {
            (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                .ignoresSafeArea()

            WebViewRepresentable(viewModel: viewModel)
                .ignoresSafeArea()

            // Following tab overlay — tiles + SAAG carousel + placeholder feed
            if viewModel.selectedTab == .following {
                (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        TeamTilesRow(viewModel: viewModel)
                        SAAGCarousel()
                        Image("FollowingFeedPlaceholder")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }
                }
                .offset(y: headerHeight)
                .ignoresSafeArea(edges: .bottom)
            }

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
