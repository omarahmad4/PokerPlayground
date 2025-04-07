//
//  ContentView.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Texas Hold'em")
                .font(.largeTitle)
                .bold()

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

            VStack {
                ForEach(game.evaluateHands(), id: \.self) { result in
                    Text(result)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            VStack {
                Text("Community Cards")
                HStack {
                    ForEach(game.communityCards) { card in
                        CardView(card: card)
                    }
                }
            }

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


#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
