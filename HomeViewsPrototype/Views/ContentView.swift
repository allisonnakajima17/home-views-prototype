import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    // Header height: nav (44) + pills (48) + spacing (8) = 100
    private let headerHeight: CGFloat = 100

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                    .ignoresSafeArea()

                WebViewRepresentable(viewModel: viewModel)
                    .ignoresSafeArea()

                // Following tab overlay — tiles + SAAG carousel
                if viewModel.selectedTab == .following {
                    VStack(spacing: 0) {
                        TeamTilesRow(viewModel: viewModel)
                        SAAGCarousel(cardStyle: .subtleFill)
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
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image("CBSEye")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                        Text("CBS Sports")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    MenuButtonView()
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                PillsRowView(viewModel: viewModel)
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
}
