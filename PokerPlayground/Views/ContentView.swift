//
//  ContentView.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import SwiftUI

/// The main game UI that shows players, cards, and controls.
/// Binds to a `GameViewModel` to manage game state.
struct ContentView: View {
    @StateObject private var game = GameViewModel()
    @State private var playerCount = 2

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Texas Hold'em")
                    .font(.largeTitle)
                    .bold()

                // Player Hands + Balances
                HStack {
                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        VStack {
                            Text(player.name + (index == game.currentPlayerIndex ? " 👈" : ""))
                                .font(.headline)
                            Text("Balance: \(player.balance)")
                                .font(.caption)
                            HStack {
                                ForEach(player.hand) { card in
                                    CardView(card: card)
                                }
                            }
                            if player.isFolded {
                                Text("(Folded)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                // Evaluated hands (description)
                VStack {
                    ForEach(game.evaluateHands(), id: \.self) { result in
                        Text(result)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                // Community cards
                VStack {
                    Text("Community Cards")
                    HStack {
                        ForEach(game.communityCards) { card in
                            CardView(card: card)
                        }
                    }
                }

                // Pot display with placeholder chip icon
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                    Text("Pot: \(game.pot) chips")
                        .font(.title3)
                }

                // Betting controls
                HStack {
                    Button("Check / Call") {
                        game.playerAction(.callOrCheck)
                    }

                    Button("Raise (+50)") {
                        game.playerAction(.raise)
                    }

                    Button("Fold") {
                        game.playerAction(.fold)
                    }

                    Button("Next Card") {
                        game.nextPhase()
                    }

                    Button("New Game") {
                        game.startNewGame(playerCount: playerCount)
                    }
                }

                // Player Count Selector
                Stepper("Players: \(playerCount)", value: $playerCount, in: 2...6)
                    .padding(.top)
            }
            .padding()
            .frame(minWidth: 800, minHeight: 500)

            // 🔴 Overlay for Hand Result Summary
            if game.showHandResult {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 16) {
                    Text("🃏 Hand Result")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    ForEach(game.handSummary, id: \.self) { line in
                        Text(line)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }

                    Button("Continue") {
                        game.showHandResult = false
                        game.startNewHand()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.black.opacity(0.85))
                .cornerRadius(12)
                .padding(.horizontal, 40)
            }
        }
    }
}


#Preview {
    ContentView()
}
