//
//  GameViewModel.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Represents the current phase of a Texas Hold'em hand.
enum GamePhase {
    case preflop, flop, turn, river, showdown
}

/// Observable class that manages the full state of the game, including
/// players, cards, deck, and phase transitions.
class GameViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var communityCards: [Card] = []
    @Published var phase: GamePhase = .preflop

    private var deck = Deck()

    /// Initializes a new game view model and starts the game immediately.
    init() {
        startNewGame()
    }

    /// Starts a new game with a given number of players (default 2).
    /// - Parameter playerCount: Number of players to include
    func startNewGame(playerCount: Int = 2) {
        deck.reset()
        communityCards = []
        phase = .preflop

        players = (1...playerCount).map { index in
            Player(name: "Player \(index)", hand: deck.deal(2))
        }
    }

    /// Deals the next card(s) based on the current game phase:
    /// - Preflop → Flop (3 cards)
    /// - Flop → Turn (1 card)
    /// - Turn → River (1 card)
    /// - River → Showdown (no cards)
    func nextPhase() {
        switch phase {
        case .preflop:
            communityCards.append(contentsOf: deck.deal(3))
            phase = .flop
        case .flop:
            communityCards.append(contentsOf: deck.deal(1))
            phase = .turn
        case .turn:
            communityCards.append(contentsOf: deck.deal(1))
            phase = .river
        case .river:
            phase = .showdown
        case .showdown:
            break
        }
    }

    /// Evaluates the best hand for each player and returns a summary string.
    /// - Returns: An array of strings describing each player's best hand.
    func evaluateHands() -> [String] {
        return players.map { player in
            let fullHand = player.hand + communityCards
            let result = HandEvaluator.evaluateBestHand(fullHand)
            return "\(player.name): \(result.description)"
        }
    }

    /// Determines the winner(s) by evaluating all player hands and comparing them.
    /// - Returns: An array of player(s) who have the best hand (handles ties).
    func winner() -> [Player] {
        let ranked = players.map { player in
            (player, HandEvaluator.evaluateBestHand(player.hand + communityCards))
        }

        guard let best = ranked.max(by: { $0.1 < $1.1 })?.1 else { return [] }

        return ranked.filter { $0.1 == best }.map { $0.0 }
    }
}
