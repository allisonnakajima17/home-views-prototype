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
        TeamTile(id: "add", tileImage: "TeamTileAdd", screenImage: nil),
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
                        // HACK: Team tile PDFs include drop shadow in canvas, so 64px
                        // compensates for the shadow padding to visually match the 56px Add tile.
                        // Proper fix: re-export PDFs without shadow baked in.
                        .frame(width: tile.screenImage != nil ? 64 : 56,
                               height: tile.screenImage != nil ? 64 : 56)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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

            // Back button
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white, .black.opacity(0.5))
            }
            .padding(.top, 54)
            .padding(.leading, 16)
        }
    }
}
