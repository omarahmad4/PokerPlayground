//
//  CardView.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import SwiftUI

struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 60, height: 90)
                .shadow(radius: 5)

            Text(card.description)
                .font(.title2)
                .foregroundColor(.black)  // 👈 Force text to be black
        }
    }
}
