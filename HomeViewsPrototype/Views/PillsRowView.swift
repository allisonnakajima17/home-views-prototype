import SwiftUI

struct PillsRowView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Tab.allCases) { tab in
                Button {
                    viewModel.selectTab(tab)
                } label: {
                    HStack(spacing: 4) {
                        if tab == .following {
                            Image("FavStar")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 14, height: 14)
                        }
                        Text(tab.label)
                            .font(.custom("TTNormsPro-DemiBold", size: 14))
                            .lineLimit(1)
                    }
                }
                .buttonStyle(.glass)
                .tint(viewModel.selectedTab == tab ? (tab.tintColor ?? .blue) : nil)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
}
