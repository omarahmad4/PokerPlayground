//
//  HandResult.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

struct HandResult: Comparable, CustomStringConvertible {
    let rank: HandRank
    let cards: [Card] // best 5-card hand

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

    private func describePair() -> String {
        let pair = findDuplicates(count: 2).first ?? "?"
        let kicker = kickerRanks(excluding: [pair]).first ?? "?"
        return "Pair of \(pair)s with \(kicker) kicker"
    }

    private func describeTwoPair() -> String {
        let pairs = findDuplicates(count: 2)
        if pairs.count >= 2 {
            let topTwo = pairs.prefix(2)
            let kicker = kickerRanks(excluding: Array(topTwo)).first ?? "?"
            return "Two Pair: \(topTwo[0])s and \(topTwo[1])s with \(kicker) kicker"
        }
        return "Two Pair"
    }

    private func describeTrips() -> String {
        let trips = findDuplicates(count: 3).first ?? "?"
        return "Three of a Kind: \(trips)s"
    }

    private func describeFullHouse() -> String {
        let trips = findDuplicates(count: 3).first ?? "?"
        let pair = findDuplicates(count: 2).first ?? "?"
        return "Full House: \(trips)s full of \(pair)s"
    }

    private func describeQuads() -> String {
        let quad = findDuplicates(count: 4).first ?? "?"
        let kicker = kickerRanks(excluding: [quad]).first ?? "?"
        return "Four of a Kind: \(quad)s with \(kicker) kicker"
    }

    private func findDuplicates(count: Int) -> [String] {
        let grouped = Dictionary(grouping: cards, by: { $0.rank })
        return grouped
            .filter { $0.value.count == count }
            .keys
            .sorted(by: rankStrength)
    }

    private func kickerRanks(excluding: [String]) -> [String] {
        return cards
            .map { $0.rank }
            .filter { !excluding.contains($0) }
            .sorted(by: rankStrength)
    }

    private func rankStrength(_ lhs: String, _ rhs: String) -> Bool {
        let order = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        return (order.firstIndex(of: lhs) ?? 0) > (order.firstIndex(of: rhs) ?? 0)
    }

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

// ✅ Keep this outside the struct
extension HandResult: Equatable {
    static func == (lhs: HandResult, rhs: HandResult) -> Bool {
        return lhs.rank == rhs.rank &&
               lhs.cards.map(\.description) == rhs.cards.map(\.description)
    }
}
