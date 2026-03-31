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
                        .foregroundColor(isSelected ? theme.surfacePrimary : Color(hex: 0x5F5F5F))
                }
                Text(label)
                    .font(.custom("TTNormsPro-DemiBold", size: 14))
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(isSelected ? theme.surfacePrimary : theme.textPrimary)
            .background(
                Capsule().fill(
                    isSelected
                        ? theme.textPrimary
                        : (isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                )
            )
        }
        .buttonStyle(.plain)
    }
}
