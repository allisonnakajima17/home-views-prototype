import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @Environment(\.theme) private var theme

    var body: some View {
        ZStack(alignment: .top) {
            theme.surfacePrimary.ignoresSafeArea()

            WebViewRepresentable(viewModel: viewModel)
                .ignoresSafeArea()

            HeaderView(viewModel: viewModel)
        }
    }
}
