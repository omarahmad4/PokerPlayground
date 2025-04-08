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

    var body: some View {
        VStack(spacing: 20) {
            Text("Texas Hold'em")
                .font(.largeTitle)
                .bold()

            // Player hands
            HStack {
                ForEach(game.players) { player in
                    VStack {
                        Text(player.name)
                            .font(.headline)
                        HStack {
                            ForEach(player.hand) { card in
                                CardView(card: card)
                            }
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

            // Controls
            HStack {
                Button("New Game") {
                    game.startNewGame()
                }

                Button("Next Card") {
                    game.nextPhase()
                }
            }
        }
        .padding()
        .frame(minWidth: 800, minHeight: 500)
    }
}

/// Provides a live SwiftUI preview of the game UI using a test game model.
#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
