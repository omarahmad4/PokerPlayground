//
//  HandResult.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Represents a finalized 5-card poker hand along with its evaluated rank.
/// Used to compare hands, break ties, and describe hands in human-readable form.
struct HandResult: Comparable, CustomStringConvertible {
    /// The rank of the hand (e.g., full house, flush, etc.)
    let rank: HandRank

    /// The actual 5 cards making up the best hand
    let cards: [Card]

    /// Describes the hand in a readable format (e.g., "Two Pair: Kings and Nines with Ace kicker")
    var description: String {
        switch rank {
        case .onePair:
            return describePair()
        case .twoPair:
            return describeTwoPair()
        case .threeOfAKind:
            return describeTrips()
        case .straight:
            guard let highCard = cards.first else { return rank.description }
            return "Straight: \(highCard.description) high"
        case .flush:
            guard let highCard = cards.first else { return rank.description }
            return "Flush: \(highCard.description) high"
        case .fullHouse:
            return describeFullHouse()
        case .fourOfAKind:
            return describeQuads()
        case .straightFlush:
            guard let highCard = cards.first else { return rank.description }
            return "Straight Flush: \(highCard.description) high"
        case .royalFlush:
            return "Royal Flush"
        case .highCard:
            guard let highCard = cards.first else { return rank.description }
            return "High Card: \(highCard.description)"
        }
    }

    // MARK: - Descriptive Helpers

    /// Describes a one-pair hand with its kicker
    private func describePair() -> String {
        let pair = findDuplicates(count: 2).first ?? "?"
        let kicker = kickerRanks(excluding: [pair]).first ?? "?"
        return "Pair of \(pair)s with \(kicker) kicker"
    }

    /// Describes a two-pair hand with its kicker
    private func describeTwoPair() -> String {
        let pairs = findDuplicates(count: 2)
        if pairs.count >= 2 {
            let topTwo = pairs.prefix(2)
            let kicker = kickerRanks(excluding: Array(topTwo)).first ?? "?"
            return "Two Pair: \(topTwo[0])s and \(topTwo[1])s with \(kicker) kicker"
        }
        return "Two Pair"
    }

    /// Describes a three-of-a-kind hand
    private func describeTrips() -> String {
        let trips = findDuplicates(count: 3).first ?? "?"
        return "Three of a Kind: \(trips)s"
    }

    /// Describes a full house hand
    private func describeFullHouse() -> String {
        let trips = findDuplicates(count: 3).first ?? "?"
        let pair = findDuplicates(count: 2).first ?? "?"
        return "Full House: \(trips)s full of \(pair)s"
    }

    /// Describes a four-of-a-kind hand with kicker
    private func describeQuads() -> String {
        let quad = findDuplicates(count: 4).first ?? "?"
        let kicker = kickerRanks(excluding: [quad]).first ?? "?"
        return "Four of a Kind: \(quad)s with \(kicker) kicker"
    }

    // MARK: - Duplicate & Kicker Logic

    /// Finds all ranks with exactly a given duplicate count (e.g., all pairs, trips, etc.)
    private func findDuplicates(count: Int) -> [String] {
        let grouped = Dictionary(grouping: cards, by: { $0.rank })
        return grouped
            .filter { $0.value.count == count }
            .keys
            .sorted(by: rankStrength)
    }

    /// Returns all card ranks sorted by strength, excluding any given ones
    private func kickerRanks(excluding: [String]) -> [String] {
        return cards
            .map { $0.rank }
            .filter { !excluding.contains($0) }
            .sorted(by: rankStrength)
    }

    /// Rank comparison helper (high cards > low cards)
    private func rankStrength(_ lhs: String, _ rhs: String) -> Bool {
        let order = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        return (order.firstIndex(of: lhs) ?? 0) > (order.firstIndex(of: rhs) ?? 0)
    }

    // MARK: - Comparable Conformance

    /// Enables sorting hands to determine which is stronger
    static func < (lhs: HandResult, rhs: HandResult) -> Bool {
        if lhs.rank != rhs.rank {
            return lhs.rank < rhs.rank
        }

        let order = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
        let lhsRanks = lhs.cards.map { order.firstIndex(of: $0.rank) ?? 0 }
        let rhsRanks = rhs.cards.map { order.firstIndex(of: $0.rank) ?? 0 }

        for (l, r) in zip(lhsRanks, rhsRanks) {
            if l != r { return l < r }
        }

        return false
    }
}

// MARK: - Equatable Conformance

/// Compares two hands by rank and exact 5-card combination
extension HandResult: Equatable {
    static func == (lhs: HandResult, rhs: HandResult) -> Bool {
        return lhs.rank == rhs.rank &&
               lhs.cards.map(\.description) == rhs.cards.map(\.description)
    }
}
