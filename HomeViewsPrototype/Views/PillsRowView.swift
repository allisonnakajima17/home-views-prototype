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
                    isSelected: viewModel.selectedTab == tab,
                    theme: theme,
                    isDark: colorScheme == .dark
                ) {
                    viewModel.selectTab(tab)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 0)
        .frame(height: 52)
    }
}

private struct PillButton: View {
    let label: String
    let isSelected: Bool
    let theme: AppTheme
    let isDark: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.custom("TTNormsPro-DemiBold", size: 14))
                .lineLimit(1)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
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
