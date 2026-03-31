import SwiftUI

struct SAAGCarousel: View {
    // Placeholder: 3 identical cards for now, replace with unique data later
    private let cardCount = 3
    var showAlt: Bool = false

    var body: some View {
        Group {
            if showAlt {
                ScrollView(.horizontal, showsIndicators: false) {
                    Image("SAAGCardAlt")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 16)
                }
            } else {
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
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}
