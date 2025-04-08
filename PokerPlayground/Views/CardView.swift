//
//  CardView.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import SwiftUI

/// Displays a single playing card visually in the UI using a white rounded rectangle and the card's text description.
struct CardView: View {
    /// The card to be displayed
    let card: Card

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 60, height: 90)
                .shadow(radius: 5)

            // Card label
            Text(card.description)
                .font(.title2)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    CardView(card: Card(rank: "A", suit: "♠️"))
}
