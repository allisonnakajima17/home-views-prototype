import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @State private var showAltCarousel = false
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
                GeometryReader { geo in
                    let w = geo.size.width

                    (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    VStack(spacing: 0) {
                        TeamTilesRow(viewModel: viewModel)
                        SAAGCarousel(showAlt: showAltCarousel)
                            .allowsHitTesting(false)
                            .id(showAltCarousel)
                        Image("FollowingFeedPlaceholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: w)
                            .clipped()
                            .allowsHitTesting(false)
                    }
                    .frame(width: w, alignment: .top)
                    .offset(y: headerHeight - viewModel.nativeScrollOffset)
                }
            }

            // Trending tab overlay — placeholder feed
            if viewModel.selectedTab == .trending {
                GeometryReader { geo in
                    let w = geo.size.width

                    (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                        .ignoresSafeArea()

                    Image("TrendingFeedPlaceholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: w)
                        .clipped()
                        .offset(y: headerHeight - viewModel.nativeScrollOffset)
                }
                .allowsHitTesting(false)
            }

            HeaderView(viewModel: viewModel)

            // Floating carousel swap button — bottom right
            if viewModel.selectedTab == .following {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showAltCarousel.toggle()
                            }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color(red: 0, green: 122/255, blue: 1))
                                .clipShape(Circle())
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
