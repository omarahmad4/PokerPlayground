//
//  Deck.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

class Deck {
    private(set) var cards: [Card] = []

    init() {
        reset()
    }

    func reset() {
        let suits = ["♠️", "♥️", "♦️", "♣️"]
        let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        cards = suits.flatMap { suit in
            ranks.map { rank in
                Card(rank: rank, suit: suit)
            }
        }
        shuffle()
    }

    func shuffle() {
        cards.shuffle()
    }

    func deal(_ count: Int) -> [Card] {
        guard count <= cards.count else { return [] }
        let hand = Array(cards.prefix(count))
        cards.removeFirst(count)
        return hand
    }
}
