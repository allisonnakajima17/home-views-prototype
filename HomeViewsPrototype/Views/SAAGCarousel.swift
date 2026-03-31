import SwiftUI

struct SAAGCarousel: View {
    // Placeholder: 3 identical cards for now, replace with unique data later
    private let cardCount = 3

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<cardCount, id: \.self) { _ in
                    Image("SAAGCard")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 176.5)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}
