//
//  Player.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//


import Foundation

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var hand: [Card] = []
}
