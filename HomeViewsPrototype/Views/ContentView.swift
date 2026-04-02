import SwiftUI

struct ContentView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    // Header height: nav row (44) + text (30) + pills (48) + spacing
    private let headerHeight: CGFloat = 140

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
                // Nav row: eye icon (glass bubble) + CBS Sports text + menu button
                HStack(spacing: 10) {
                    Image("CBSEye")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .glassEffect(.regular, in: .circle)

                    Text("CBS Sports")
                        .font(.custom("TTNormsPro-Bold", size: 20))
                        .offset(y: min(0, -viewModel.nativeScrollOffset))
                        .opacity(max(0, 1 - viewModel.nativeScrollOffset / 30))

                    Spacer()

                    MenuButtonView()
                }
                .padding(.horizontal, 16)
                .frame(height: 52)

                PillsRowView(viewModel: viewModel)
            }
            .padding(.top, safeAreaTop)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary, location: 0.6),
                        .init(color: (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary).opacity(0), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
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

    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 59
    }
}
