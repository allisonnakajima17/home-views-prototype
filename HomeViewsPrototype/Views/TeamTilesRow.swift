import SwiftUI

struct TeamTile: Identifiable {
    let id: String
    let tileImage: String
    let screenImage: String?
}

struct TeamTilesRow: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let tiles = [
        TeamTile(id: "illinois", tileImage: "TeamTileIllinois", screenImage: "ScreenIllinois"),
        TeamTile(id: "bears", tileImage: "TeamTileChicagoBears", screenImage: "ScreenBears"),
        TeamTile(id: "lafc", tileImage: "TeamTileLAFC", screenImage: "ScreenLAFC"),
        TeamTile(id: "add", tileImage: "TeamTileAdd", screenImage: "ScreenAdd"),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tiles) { tile in
                Button {
                    if tile.screenImage != nil {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectedTeamScreen = tile
                        }
                    }
                } label: {
                    if tile.id == "add" {
                        AddTileView(isDark: colorScheme == .dark)
                    } else {
                        Image(tile.tileImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
}

struct AddTileView: View {
    let isDark: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isDark ? Color(hex: 0x333333) : Color(hex: 0xF2F2F2))
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(isDark ? Color(hex: 0x999999) : Color(hex: 0x5F5F5F))
        }
        .frame(width: 56, height: 56)
    }
}

struct TeamScreenView: View {
    let imageName: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            // Invisible dismiss button — still tappable
            Button(action: onDismiss) {
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 54)
            .padding(.leading, 16)
        }
    }
}
