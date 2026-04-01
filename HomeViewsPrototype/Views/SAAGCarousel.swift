import SwiftUI

struct SAAGCarousel: View {
    @Environment(\.colorScheme) private var colorScheme
    private let games = SAAGCarousel.sampleGames

    private var borderColor: Color {
        colorScheme == .dark ? Color(hex: 0x2A2A2A) : Color(hex: 0xDCDCDC)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                    GameTrackerCardView(game: game)

                    if index < games.count - 1 {
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
            homeTeam: TeamInfo(abbreviation: "IOWA", record: "10-10", accentColor: Color(hex: 0x1A1A1A)),
            awayTeam: TeamInfo(abbreviation: "ILL", record: "9-4", accentColor: Color(hex: 0xE04E39)),
            homeScore: 59,
            awayScore: 71,
            winnerIsHome: false
        ),
        // Card 2: UConn vs ILL — Upcoming
        GameCardData(
            state: .upcoming,
            homeTeam: TeamInfo(abbreviation: "ILL", record: "7-3", accentColor: Color(hex: 0xE04E39)),
            awayTeam: TeamInfo(abbreviation: "UCONN", record: "7-3", accentColor: Color(hex: 0x0E1A3E)),
            gameTime: "6:09pm",
            network: "CBS",
            homeOdds: "14",
            awayOdds: "-300"
        ),
        // Card 3: Austin vs LAFC — Live
        GameCardData(
            state: .live,
            homeTeam: TeamInfo(abbreviation: "LAFC", record: "5-5", accentColor: Color(hex: 0xC39E6D)),
            awayTeam: TeamInfo(abbreviation: "AUSTIN", record: "5-4", accentColor: Color(hex: 0x00B140)),
            periodClock: "1st 10:52",
            homeLiveScore: 7,
            awayLiveScore: 3
        ),
        // Card 4: TEN vs DAL — Final
        GameCardData(
            state: .final_,
            homeTeam: TeamInfo(abbreviation: "DAL", record: "3-8", accentColor: Color(hex: 0x003594)),
            awayTeam: TeamInfo(abbreviation: "TEN", record: "7-3", accentColor: Color(hex: 0x4B92DB)),
            homeScore: 14,
            awayScore: 30,
            winnerIsHome: false
        ),
        // Card 5: TB vs NO — Live
        GameCardData(
            state: .live,
            homeTeam: TeamInfo(abbreviation: "NO", record: "7-3", accentColor: Color(hex: 0xD3BC8D)),
            awayTeam: TeamInfo(abbreviation: "TB", record: "7-3", accentColor: Color(hex: 0xD50A0A)),
            periodClock: "1st 10:52",
            homeLiveScore: 14,
            awayLiveScore: 14
        ),
        // Card 6: CAR vs PHI — Upcoming
        GameCardData(
            state: .upcoming,
            homeTeam: TeamInfo(abbreviation: "PHI", record: "7-3", accentColor: Color(hex: 0x004C54)),
            awayTeam: TeamInfo(abbreviation: "CAR", record: "7-3", accentColor: Color(hex: 0x0085CA)),
            gameTime: "4:05pm",
            network: "CBS",
            homeOdds: "14",
            awayOdds: "-1.5"
        ),
    ]
}
