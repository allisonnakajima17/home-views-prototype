import SwiftUI

struct TeamTile: Identifiable {
    let id: String
    let tileImage: String
    let screenImage: String?
}

struct TeamTilesRow: View {
    @State private var selectedScreen: TeamTile?

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
                        selectedScreen = tile
                    }
                } label: {
                    Image(tile.tileImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .fullScreenCover(item: $selectedScreen) { tile in
            if let screenImage = tile.screenImage {
                TeamScreenView(imageName: screenImage) {
                    selectedScreen = nil
                }
            }
        }
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
