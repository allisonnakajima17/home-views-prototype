import SwiftUI

struct NavBarView: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            CBSLogoView(color: theme.textPrimary)
                .frame(width: 120, height: 14)

            Spacer()

            MenuButtonView()
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
}

struct CBSLogoView: View {
    let color: Color

    var body: some View {
        Image("CBSLogo")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(color)
    }
}

struct MenuButtonView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: 0) {
            Text("Menu")
                .font(.custom("TTNormsPro-DemiBold", size: 14))
                .foregroundColor(theme.textPrimary)
                .padding(.trailing, 4)

            // Three overlapping circles with plus icons
            HStack(spacing: -4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(theme.surfaceTertiary)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(theme.textSecondary)
                        )
                        .overlay(
                            Circle()
                                .stroke(theme.surfaceTertiary, lineWidth: 2)
                        )
                        .zIndex(Double(3 - index))
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(theme.surfaceTertiary))
    }
}
