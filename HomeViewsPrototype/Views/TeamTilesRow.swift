import SwiftUI

struct TeamTile: Identifiable {
    let id: String
    let tileImage: String
    let screenImage: String?
}

struct TeamTilesRow: View {
    @Bindable var viewModel: AppViewModel

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
                    Image(tile.tileImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
