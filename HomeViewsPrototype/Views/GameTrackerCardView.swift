import SwiftUI

struct GameTrackerCardView: View {
    let game: GameCardData
    @Environment(\.colorScheme) private var colorScheme

    private let contentWidth: CGFloat = 136
    private let textLive = Color(hex: 0x004ACE)

    private var isDark: Bool { colorScheme == .dark }
    private var textPrimary: Color { isDark ? .white : Color(hex: 0x181818) }
    private var textSecondary: Color { isDark ? Color(hex: 0x999999) : Color(hex: 0x5F5F5F) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerRow
            VStack(spacing: 4) {
                teamRow(
                    team: game.awayTeam,
                    scoreOrOdds: awayScoreText,
                    isWinner: game.state == .final_ && game.winnerIsHome == false,
                    scoreColor: awayScoreColor
                )
                teamRow(
                    team: game.homeTeam,
                    scoreOrOdds: homeScoreText,
                    isWinner: game.state == .final_ && game.winnerIsHome == true,
                    scoreColor: homeScoreColor
                )
            }
        }
        .frame(width: contentWidth)
        .padding(8)
    }

    // MARK: - Header

    @ViewBuilder
    private var headerRow: some View {
        HStack {
            switch game.state {
            case .final_:
                Text("FINAL")
                    .font(.custom("TTNormsPro-Bold", size: 10))
                    .tracking(0.25)
                    .foregroundColor(textPrimary)
                    .lineLimit(1)
            case .upcoming:
                Text(game.gameTime ?? "")
                    .font(.custom("TTNormsPro-Bold", size: 10))
                    .tracking(0.25)
                    .foregroundColor(textSecondary)
                    .lineLimit(1)
            case .live:
                Text(game.periodClock ?? "")
                    .font(.custom("TTNormsPro-Bold", size: 10))
                    .tracking(0.25)
                    .foregroundColor(textLive)
                    .lineLimit(1)
            }

            Spacer()

            if let network = game.network, game.state == .upcoming {
                Text(network)
                    .font(.custom("TTNormsPro-Bold", size: 10))
                    .tracking(0.25)
                    .foregroundColor(textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(height: 12)
    }

    // MARK: - Team Row

    @ViewBuilder
    private func teamRow(team: TeamInfo, scoreOrOdds: String, isWinner: Bool, scoreColor: Color) -> some View {
        HStack {
            HStack(spacing: 4) {
                Image(team.logoName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)

                Text(team.abbreviation)
                    .font(.custom("TTNormsPro-Bold", size: 16))
                    .foregroundColor(isWinner || game.state != .final_ ? textPrimary : textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Text(team.record)
                    .font(.custom("TTNormsPro-Regular", size: 10))
                    .tracking(0.25)
                    .foregroundColor(textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(scoreOrOdds)
                .font(.custom(scoreFont, size: scoreFontSize))
                .foregroundColor(scoreColor)
                .lineLimit(1)
        }
    }

    // MARK: - Score/Odds Helpers

    private var awayScoreText: String {
        switch game.state {
        case .final_:
            return game.awayScore.map { "\($0)" } ?? ""
        case .upcoming:
            return game.awayOdds ?? ""
        case .live:
            return game.awayLiveScore.map { "\($0)" } ?? ""
        }
    }

    private var homeScoreText: String {
        switch game.state {
        case .final_:
            return game.homeScore.map { "\($0)" } ?? ""
        case .upcoming:
            return game.homeOdds ?? ""
        case .live:
            return game.homeLiveScore.map { "\($0)" } ?? ""
        }
    }

    private var awayScoreColor: Color {
        switch game.state {
        case .final_:
            return game.winnerIsHome == false ? textPrimary : textSecondary
        case .upcoming:
            return textSecondary
        case .live:
            return textPrimary
        }
    }

    private var homeScoreColor: Color {
        switch game.state {
        case .final_:
            return game.winnerIsHome == true ? textPrimary : textSecondary
        case .upcoming:
            return textSecondary
        case .live:
            return textPrimary
        }
    }

    private var scoreFont: String {
        switch game.state {
        case .final_:
            return "FlamaCond-Bold"
        case .upcoming:
            return "TTNormsPro-Regular"
        case .live:
            return "TTNormsPro-Bold"
        }
    }

    private var scoreFontSize: CGFloat {
        game.state == .upcoming ? 12 : 16
    }
}
