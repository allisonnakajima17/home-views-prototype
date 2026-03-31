import SwiftUI

struct HeaderView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            NavBarView()

            // Pills — animate height, no own background
            VStack(spacing: 0) {
                PillsRowView(viewModel: viewModel)
                    .frame(height: 52)
                Spacer().frame(height: 8)
            }
            .frame(height: viewModel.pillsVisible ? 60 : 0, alignment: .top)
            .clipped()
        }
        .background(
            ZStack {
                // Blur layer
                VariableBlurView()
                    .opacity(viewModel.blurOpacity)

                // Fog layer
                (colorScheme == .dark ? Color.black : Color.white)
                    .opacity(0.3)

                // Tint gradient — covers full header
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

                // Gradual fade to surface color across full header
                LinearGradient(
                    colors: [
                        theme.surfacePrimary.opacity(0),
                        theme.surfacePrimary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
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
