//
//  GameViewModel.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//


import Foundation

class GameViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var communityCards: [Card] = []

    private var deck = Deck()
    
    enum GamePhase {
        case preflop, flop, turn, river, showdown
    }
    
    @Published var phase: GamePhase = .preflop

    init() {
        startNewGame()
    }

    func startNewGame(playerCount: Int = 2) {
        deck.reset()
        communityCards = []
        phase = .preflop

        players = (1...playerCount).map { index in
            Player(name: "Player \(index)", hand: deck.deal(2))
        }
    }

    func dealFlop() {
        communityCards.append(contentsOf: deck.deal(3))
    }

    func dealTurn() {
        communityCards.append(contentsOf: deck.deal(1))
    }

    func dealRiver() {
        communityCards.append(contentsOf: deck.deal(1))
    }
    
    func evaluateHands() -> [String] {
        return players.map { player in
            let fullHand = player.hand + communityCards
            let result = HandEvaluator.evaluateBestHand(fullHand)
            return "\(player.name): \(result.description)"
        }
    }
    
    func winner() -> [Player] {
        let ranked = players.map { player in
            (player, HandEvaluator.evaluateBestHand(player.hand + communityCards))
        }

        guard let best = ranked.max(by: { $0.1 < $1.1 })?.1 else { return [] }

        return ranked.filter { $0.1 == best }.map { $0.0 }
    }
    
    func nextPhase() {
        switch phase {
        case .preflop:
            communityCards.append(contentsOf: deck.deal(3)) // flop
            phase = .flop
        case .flop:
            communityCards.append(contentsOf: deck.deal(1)) // turn
            phase = .turn
        case .turn:
            communityCards.append(contentsOf: deck.deal(1)) // river
            phase = .river
        case .river:
            phase = .showdown
        case .showdown:
            break // no more cards
        }
    }
}


