//
//  Player.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Represents a player in the game, including their name and current hand.
struct Player: Identifiable {
    let id = UUID()

    /// Display name for the player
    var name: String

    /// The two hole cards dealt to the player
    var hand: [Card] = []
}
