import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            (colorScheme == .dark ? Color(hex: 0x212121) : theme.surfacePrimary)
                .ignoresSafeArea()

            WebViewRepresentable(viewModel: viewModel)
                .ignoresSafeArea()

            HeaderView(viewModel: viewModel)
        }
    }
}
