import SwiftUI

enum GameState {
    case final_
    case live
    case upcoming
}

struct TeamInfo {
    let abbreviation: String
    let record: String
    let accentColor: Color
}

struct GameCardData: Identifiable {
    let id = UUID()
    let state: GameState
    let homeTeam: TeamInfo
    let awayTeam: TeamInfo

    // Final state
    var homeScore: Int?
    var awayScore: Int?
    var winnerIsHome: Bool?

    // Upcoming state
    var gameTime: String?
    var network: String?
    var homeOdds: String?
    var awayOdds: String?

    // Live state
    var periodClock: String?
    var situationText: String?
    var homeLiveScore: Int?
    var awayLiveScore: Int?
}
