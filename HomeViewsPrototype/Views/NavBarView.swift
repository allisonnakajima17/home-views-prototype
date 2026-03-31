import SwiftUI

struct NavBarView: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            CBSLogoView(color: colorScheme == .dark ? .white : Color(hex: 0x004ACE))
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
    var body: some View {
        Image("MenuButton")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 32)
    }
}
