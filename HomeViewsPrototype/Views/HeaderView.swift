import SwiftUI

struct HeaderView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            // Safe area spacer
            Color.clear
                .frame(height: 0)
                .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }

            // Header content
            VStack(spacing: 0) {
                NavBarView()

                // Pills slide in/out vertically
                PillsRowView(viewModel: viewModel)
                    .frame(height: 52)
                    .offset(y: viewModel.pillsVisible ? 0 : -52)
                    .opacity(viewModel.pillsVisible ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.82),
                        value: viewModel.pillsVisible
                    )
                    .frame(height: viewModel.pillsVisible ? 52 : 0, alignment: .top)
                    .clipped()

                // Bottom padding
                Spacer().frame(height: viewModel.pillsVisible ? 8 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.82),
                        value: viewModel.pillsVisible
                    )
            }
        }
        .background(
            ZStack {
                // Blur layer
                VariableBlurView()
                    .opacity(viewModel.blurOpacity)

                // Fog layer
                (colorScheme == .dark ? Color.black : Color.white)
                    .opacity(0.3)

                // Tint gradient
                ForEach(Tab.allCases) { tab in
                    if let tintColor = tab.tintColor {
                        LinearGradient(
                            colors: [tintColor.opacity(0.12), tintColor.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(viewModel.selectedTab == tab ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTab)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        )
    }
}

// UIVisualEffectView wrapper for proper frosted glass blur
struct VariableBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
