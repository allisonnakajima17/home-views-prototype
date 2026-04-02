import SwiftUI

struct PillsRowView: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Tab.allCases) { tab in
                PillButton(
                    label: tab.label,
                    icon: tab == .following ? "FavStar" : nil,
                    isSelected: viewModel.selectedTab == tab,
                    theme: theme,
                    isDark: colorScheme == .dark
                ) {
                    viewModel.selectTab(tab)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 0)
        .frame(height: 48)
    }
}

// NOTE: These pills should utilize the design system pills.
// Only the active state fill color should change per-tab — all other
// styling (shape, font, padding, inactive state) comes from the design system.
private struct PillButton: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let theme: AppTheme
    let isDark: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 14, height: 14)
                        // NOTE: Icon color should follow design system pill active/inactive states
                        .foregroundColor(isSelected ? (isDark ? .black : theme.surfacePrimary) : (isDark ? Color(hex: 0xC8C8C8) : Color(hex: 0x5F5F5F)))
                }
                Text(label)
                    .font(.custom("TTNormsPro-DemiBold", size: 14))
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            // NOTE: Text color should follow design system pill active/inactive states
            .foregroundColor(
                isSelected
                    ? (isDark ? .black : theme.surfacePrimary)
                    : (isDark ? .white : theme.textPrimary)
            )
            // NOTE: Active state fill color is the only value that should change per-tab
            .background(
                Capsule().fill(
                    isSelected
                        ? (isDark ? Color(hex: 0xF2F2F2) : theme.textPrimary)
                        : (isDark ? Color(hex: 0x333333) : Color(hex: 0xF2F2F2))
                )
            )
        }
        .buttonStyle(.plain)
    }
}
