//
//  Card.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Represents a standard playing card with a rank and a suit.
/// Conforms to `Identifiable` for use in SwiftUI lists and ForEach views.
struct Card: Identifiable {
    let id = UUID()
    
    /// The rank of the card, e.g., "A", "K", "10"
    let rank: String
    
    /// The suit of the card, e.g., "♠️", "♥️", "♦️", "♣️"
    let suit: String

    /// Readable card representation, e.g., "A♠️"
    var description: String {
        "\(rank)\(suit)"
    }
}
