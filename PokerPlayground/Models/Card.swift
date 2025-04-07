//
//  Card.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    let rank: String  // e.g. "A", "2", ..., "K"
    let suit: String  // e.g. "♠️", "♥️", "♦️", "♣️"

    var description: String {
        "\(rank)\(suit)"
    }
}
