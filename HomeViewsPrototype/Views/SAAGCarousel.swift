import SwiftUI

enum CardStyle: CaseIterable {
    case dividers
    case subtleFill
    case subtleStroke
    case fillShadow

    var label: String {
        switch self {
        case .dividers: return "Dividers"
        case .subtleFill: return "Fill"
        case .subtleStroke: return "Stroke"
        case .fillShadow: return "Shadow"
        }
    }
}

struct SAAGCarousel: View {
    @Environment(\.colorScheme) private var colorScheme
    var cardStyle: CardStyle = .dividers
    private let games = SAAGCarousel.sampleGames

    private var borderColor: Color {
        colorScheme == .dark ? Color(hex: 0x2A2A2A) : Color(hex: 0xDCDCDC)
    }

    private var cardFill: Color {
        colorScheme == .dark ? Color(hex: 0x2A2A2A) : Color(hex: 0xF5F5F5)
    }

    private var cardStroke: Color {
        colorScheme == .dark ? Color(hex: 0x3A3A3A) : Color(hex: 0xE0E0E0)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: cardStyle == .dividers ? 4 : 8) {
                ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                    GameTrackerCardView(game: game)
                        .modifier(CardStyleModifier(style: cardStyle, fill: cardFill, stroke: cardStroke))

                    if cardStyle == .dividers && index < games.count - 1 {
                        Rectangle()
                            .fill(borderColor)
                            .frame(width: 0.5, height: 64)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Sample Data (matches Figma)

    private static let sampleGames: [GameCardData] = [
        // Card 1: ILL vs Iowa — Final
        GameCardData(
            state: .final_,
            homeTeam: TeamInfo(abbreviation: "IOWA", record: "10-10", logoName: "Iowa Hawkeyes (IOWA)", accentColor: Color(hex: 0x1A1A1A)),
            awayTeam: TeamInfo(abbreviation: "ILL", record: "9-4", logoName: "Illinois Fighting Illini (ILL)", accentColor: Color(hex: 0xE04E39)),
            homeScore: 59,
            awayScore: 71,
            winnerIsHome: false
        ),
        // Card 2: UConn vs ILL — Upcoming
        GameCardData(
            state: .upcoming,
            homeTeam: TeamInfo(abbreviation: "ILL", record: "7-3", logoName: "Illinois Fighting Illini (ILL)", accentColor: Color(hex: 0xE04E39)),
            awayTeam: TeamInfo(abbreviation: "UCONN", record: "7-3", logoName: "UConn Huskies (UCONN)", accentColor: Color(hex: 0x0E1A3E)),
            gameTime: "6:09pm",
            network: "CBS",
            homeOdds: "14",
            awayOdds: "-300"
        ),
        // Card 3: Austin vs LAFC — Live
        GameCardData(
            state: .live,
            homeTeam: TeamInfo(abbreviation: "LAFC", record: "5-5", logoName: "Los Angeles FC", accentColor: Color(hex: 0xC39E6D)),
            awayTeam: TeamInfo(abbreviation: "AUSTIN", record: "5-4", logoName: "Austin FC", accentColor: Color(hex: 0x00B140)),
            periodClock: "1st 10:52",
            homeLiveScore: 7,
            awayLiveScore: 3
        ),
    ]
}

// MARK: - Card Style Modifier

struct CardStyleModifier: ViewModifier {
    let style: CardStyle
    let fill: Color
    let stroke: Color

    func body(content: Content) -> some View {
        switch style {
        case .dividers:
            content
        case .subtleFill:
            content
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(fill)
                )
        case .subtleStroke:
            content
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(stroke, lineWidth: 1)
                )
        case .fillShadow:
            content
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(fill)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                )
        }
    }
}
