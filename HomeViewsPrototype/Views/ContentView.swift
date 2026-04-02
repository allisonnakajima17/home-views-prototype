import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    // Header height: nav row (52) + pills (48) + spacing
    private let headerHeight: CGFloat = 120

    private var tintColor: Color {
        viewModel.selectedTab.tintColor ?? Color(hex: 0x004ACE)
    }

    var body: some View {
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

            // Header
            VStack(alignment: .leading, spacing: 0) {
                // Nav row: eye (glass bubble) + CBS SPORTS text + team icons (glass pill)
                HStack(spacing: 10) {
                    Image("CBSEye")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 23, height: 23)
                        .padding(10)
                        .glassEffect(.regular, in: .circle)

                    Text("CBS SPORTS")
                        .font(.custom("TTNormsPro-Bold", size: 23))
                        .tracking(-0.46)
                        .blendMode(.plusLighter)
                        .offset(y: min(0, -viewModel.nativeScrollOffset))
                        .opacity(max(0, 1 - viewModel.nativeScrollOffset / 30))

                    Spacer()

                    MenuButtonView()
                }
                .padding(.horizontal, 16)
                .frame(height: 52)

                PillsRowView(viewModel: viewModel)
            }
            .background(
                ZStack {
                    // Team tint color layer — bleeds through the semi-transparent surface
                    tintColor
                        .ignoresSafeArea(edges: .top)

                    // Surface color at 92% opacity — lets tint show through at top
                    LinearGradient(
                        stops: [
                            .init(color: (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary).opacity(0.92), location: 0.0),
                            .init(color: colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                }
            )
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
