//
//  GameViewModel.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation



private var dealerIndex: Int = 0
private let smallBlindAmount = 10
private let bigBlindAmount = 20

enum GamePhase {
    case preflop, flop, turn, river, showdown
}

/// Enum representing available player actions
enum PlayerAction {
    case callOrCheck
    case fold
    case raise
}

/// Manages full game state, including players, AI, turn flow, pot, and hand resolution.
class GameViewModel: ObservableObject {
    @Published var showHandResult = false
    @Published var handSummary: [String] = []
    @Published var players: [Player] = []
    @Published var communityCards: [Card] = []
    @Published var phase: GamePhase = .preflop
    @Published var pot: Int = 0
    @Published var currentPlayerIndex: Int = 0
    private var actedPlayerIndices: Set<Int> = []
    private var highestBet: Int = 0
    private var deck = Deck()
 
    /// Starts a new hand (within the same session), preserving balances.
    func startNewHand() {
        deck.reset()
        communityCards = []
        pot = 0
        phase = .preflop
        highestBet = 0
        actedPlayerIndices = []
        
        // Rotate dealer
        dealerIndex = (dealerIndex + 1) % players.count
        let sbIndex = (dealerIndex + 1) % players.count
        let bbIndex = (dealerIndex + 2) % players.count

        // Deal cards and reset player state
        for i in players.indices {
            players[i].hand = deck.deal(2)
            players[i].isFolded = false
            players[i].currentBet = 0
            players[i].isDealer = (i == dealerIndex)
            players[i].isSmallBlind = (i == sbIndex)
            players[i].isBigBlind = (i == bbIndex)
        }

        // Post blinds
        players[sbIndex].balance -= smallBlindAmount
        players[sbIndex].currentBet = smallBlindAmount
        pot += smallBlindAmount

        players[bbIndex].balance -= bigBlindAmount
        players[bbIndex].currentBet = bigBlindAmount
        pot += bigBlindAmount

        highestBet = bigBlindAmount

        print("Dealer: \(players[dealerIndex].name)")
        print("Small Blind: \(players[sbIndex].name) posts \(smallBlindAmount)")
        print("Big Blind: \(players[bbIndex].name) posts \(bigBlindAmount)")
        print("Pot initialized at \(pot)")

        // Start with player after big blind
        currentPlayerIndex = (bbIndex + 1) % players.count

        // Trigger AI if needed
        if !players[currentPlayerIndex].isHuman {
            handleAITurn()
        }
    }
    

    /// Starts an entirely new game session.
    /// - Parameter playerCount: Number of total players (1 human, rest AI)
    func startNewGame(playerCount: Int = 2) {
        deck.reset()
        communityCards = []
        pot = 0
        phase = .preflop
        currentPlayerIndex = 0
   
        players = (1...playerCount).map { index in
            Player(name: "Player \(index)",
                   hand: [],
                   balance: 1000,
                   isFolded: false,
                   isHuman: index == 1)
        }

        startNewHand() // ✅ Start first hand
    }

    /// Handles an action (check/call, raise, or fold) from the current player.
    func playerAction(_ action: PlayerAction) {
        guard players.indices.contains(currentPlayerIndex),
              !players[currentPlayerIndex].isFolded else { return }

        let player = players[currentPlayerIndex]
        let toCall = highestBet - player.currentBet
        var contribution = 0

        print("→ BEFORE action: \(player.name) | currentBet: \(player.currentBet) | balance: \(player.balance)")
        print("To call for \(player.name): \(toCall) | HighestBet: \(highestBet)")

        switch action {
        case .callOrCheck:
            // Match current highest bet
            contribution = min(player.balance, toCall)

        case .raise:
            let raiseAmount = 50
            let totalRaise = toCall + raiseAmount
            if player.balance <= toCall {
                contribution = player.balance  // all-in call
            } else {
                contribution = min(player.balance, totalRaise)
            }

        case .fold:
            players[currentPlayerIndex].isFolded = true
            print("🟥 \(player.name) folds.")
        }

        if action != .fold {
            players[currentPlayerIndex].balance -= contribution
            players[currentPlayerIndex].currentBet += contribution
            highestBet = max(highestBet, players[currentPlayerIndex].currentBet)
            pot += contribution
            actedPlayerIndices.insert(currentPlayerIndex)
        }
        

        print("\(player.name) chose \(action).")
        print("Contributed: \(contribution) | Balance: \(players[currentPlayerIndex].balance) | Pot: \(pot) | HighestBet: \(highestBet)")
        print("→ AFTER action: \(player.name) | currentBet: \(players[currentPlayerIndex].currentBet) | balance: \(players[currentPlayerIndex].balance)")
        print("--------------------------------------------------")

        advanceTurn()
    }

    /// Advances the turn to the next active player, or resolves the hand if done.
    private func advanceTurn() {
        guard phase != .showdown else { return }
        let activePlayers = players.enumerated().filter { !$0.element.isFolded }
        let remainingIndices = activePlayers.map(\.offset)

        guard remainingIndices.count > 1 else {
            endHand(winners: [players[remainingIndices.first!]])
            return
        }

        // Check if all active players have matched the highest bet
        let everyoneActed = activePlayers.allSatisfy { actedPlayerIndices.contains($0.offset) }
        let everyoneMatched = activePlayers.allSatisfy { $0.element.currentBet == highestBet }

        if everyoneActed && everyoneMatched {
            print("✅ All active players have acted and matched the highest bet (\(highestBet)). Advancing phase.")
            nextPhase()
            return
        }

        repeat {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        } while players[currentPlayerIndex].isFolded

        if !players[currentPlayerIndex].isHuman {
            handleAITurn()
        }
        
    }

    /// Handles AI turn with simple logic
    private func handleAITurn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let player = self.players[self.currentPlayerIndex]
            let handStrength = HandEvaluator.evaluateHand(player.hand)

            let shouldFold: Bool = {
                switch handStrength {
                case .highCard: return Bool.random()
                case .onePair: return false
                default: return false
                }
            }()

            let action: PlayerAction = shouldFold ? .fold : .callOrCheck
            self.playerAction(action)
        }
    }

    /// Deals the next community card(s) and resets action tracking.
    func nextPhase() {
        // ✅ Prevent looping after showdown
        if phase == .showdown {
            return
        }

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
            evaluateAndEnd()
        case .showdown:
            break // this is now unreachable anyway
        }

        actedPlayerIndices = []
        print("→ Phase advanced to: \(phase)")

        for i in players.indices {
            players[i].currentBet = 0
        }

        highestBet = 0
        advanceTurn()
    }

    /// Evaluates all hands and awards pot to winner(s)
    private func evaluateAndEnd() {
        let winners = winner()
        endHand(winners: winners)
    }

    /// Ends the hand, awards pot to winner(s), and prepares new hand.
    private func endHand(winners: [Player]) {
        let splitPot = pot / winners.count
        var summary: [String] = []

        for i in players.indices {
            let bet = players[i].currentBet  // ✅ Capture before resetting
            let wasWinner = winners.contains(where: { $0.id == players[i].id })
            let won = wasWinner ? splitPot : 0
            let net = won - bet
            players[i].balance += won
            summary.append("\(players[i].name): Bet \(bet), Won \(won), Net \(net), New Balance: \(players[i].balance)")
        }

        handSummary = summary
        showHandResult = true

        print("🏆 Winners: \(winners.map { $0.name }.joined(separator: ", "))")
        print("💰 Pot awarded: \(pot)")

        // Now safe to reset
        pot = 0
        highestBet = 0
        for i in players.indices {
            players[i].currentBet = 0
        }
    }
    
        

        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.startNewHand()
  

    /// Evaluates the best hand for each player for display or comparison.
    func evaluateHands() -> [String] {
        return players.map { player in
            let fullHand = player.hand + communityCards
            let result = HandEvaluator.evaluateBestHand(fullHand)
            return "\(player.name): \(result.description)"
        }
    }

    /// Finds the winning player(s), accounting for ties.
    func winner() -> [Player] {
        let activePlayers = players.filter { !$0.isFolded }
        let ranked = activePlayers.map { player in
            (player, HandEvaluator.evaluateBestHand(player.hand + communityCards))
        }

        guard let best = ranked.max(by: { $0.1 < $1.1 })?.1 else { return [] }

        return ranked.filter { $0.1 == best }.map { $0.0 }
    }
}
