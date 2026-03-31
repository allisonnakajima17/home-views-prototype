import SwiftUI

struct SAAGCarousel: View {
    // Placeholder: 3 identical cards for now, replace with unique data later
    private let cardCount = 3
    @State private var showAlt = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showAlt.toggle()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.trailing, 16)
            .padding(.bottom, 4)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}
