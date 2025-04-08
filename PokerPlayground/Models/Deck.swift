//
//  Deck.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Manages a standard deck of 52 playing cards, including shuffle and deal logic.
class Deck {
    /// The current cards in the deck, exposed as read-only
    private(set) var cards: [Card] = []

    /// Initializes the deck and populates it with cards
    init() {
        reset()
    }

    /// Resets the deck to a full 52-card set and shuffles it
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

    /// Randomizes the order of cards in the deck
    func shuffle() {
        cards.shuffle()
    }

    /// Deals a given number of cards from the top of the deck
    /// - Parameter count: Number of cards to deal
    /// - Returns: An array of dealt `Card` objects
    func deal(_ count: Int) -> [Card] {
        guard count <= cards.count else { return [] }
        let hand = Array(cards.prefix(count))
        cards.removeFirst(count)
        return hand
    }
}
