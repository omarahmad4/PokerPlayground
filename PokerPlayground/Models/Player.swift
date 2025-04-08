//
//  Player.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Represents a player in the game, including their name, hand, and status.
struct Player: Identifiable {
    let id = UUID()
    
    /// Display name for the player
    var name: String
    
    /// The two hole cards dealt to the player
    var hand: [Card] = []
    var balance: Int = 1000
    var isFolded: Bool = false
    var isHuman: Bool = false
    var isDealer: Bool = false
    var isSmallBlind: Bool = false
    var isBigBlind: Bool = false
    
    /// The current amount this player has committed in this betting round.
    var currentBet: Int = 0
}

