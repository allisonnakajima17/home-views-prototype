import SwiftUI

struct TeamTilesRow: View {
    private let tiles = ["TeamTileIllinois", "TeamTileChicagoBears", "TeamTileLAFC", "TeamTileAdd"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tiles, id: \.self) { tile in
                Image(tile)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 56, height: 56)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
