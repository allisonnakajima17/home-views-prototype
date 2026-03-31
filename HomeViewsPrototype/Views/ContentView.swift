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

            // Team tiles — fixed below header on Following tab
            if viewModel.selectedTab == .following {
                VStack {
                    Spacer().frame(height: headerHeight)
                    TeamTilesRow()
                    Spacer()
                }
            }

            HeaderView(viewModel: viewModel)
        }
    }
}
