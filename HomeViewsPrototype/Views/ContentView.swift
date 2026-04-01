import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @State private var useGradientStyle = false
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

            // Following tab overlay — tiles + SAAG carousel
            if viewModel.selectedTab == .following {
                VStack(spacing: 0) {
                    TeamTilesRow(viewModel: viewModel)
                    SAAGCarousel(cardStyle: useGradientStyle ? .teamGradient : .subtleStroke)
                    // Placeholder feed image (temporarily disabled)
                    // Image("FollowingFeedPlaceholder")
                    //     .resizable()
                    //     .scaledToFill()
                    //     .frame(maxWidth: .infinity)
                    //     .clipped()
                    //     .allowsHitTesting(false)
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

            // Floating style toggle
            if viewModel.selectedTab == .following {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                useGradientStyle.toggle()
                            }
                        } label: {
                            Text(useGradientStyle ? "Gradient" : "Stroke")
                                .font(.custom("TTNormsPro-DemiBold", size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(red: 0, green: 122/255, blue: 1))
                                .clipShape(Capsule())
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
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
