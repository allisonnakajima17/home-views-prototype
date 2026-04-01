import SwiftUI

struct TeamLogoPlaceholder: View {
    let abbreviation: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
            Text(String(abbreviation.prefix(1)))
                .font(.custom("TTNormsPro-Bold", size: 10))
                .foregroundColor(.white)
        }
        .frame(width: 20, height: 20)
    }
}
