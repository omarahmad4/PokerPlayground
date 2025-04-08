//
//  HandEvaluator.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//

import Foundation

/// Responsible for evaluating poker hands from a set of cards.
/// Provides logic for hand ranking, best hand selection, and utility helpers.
struct HandEvaluator {

    /// Evaluates the best 5-card hand from a set of 7 cards (e.g., 2 hole + 5 community).
    /// - Parameter cards: Full set of 7 cards
    /// - Returns: `HandResult` containing the best hand and its rank
    static func evaluateBestHand(_ cards: [Card]) -> HandResult {
        let allCombos = combinations(of: cards, choosing: 5)
        let rankedHands = allCombos.map { combo in
            (combo, evaluateHand(combo))
        }

        guard let best = rankedHands.max(by: { $0.1 < $1.1 }) else {
            return HandResult(rank: .highCard, cards: [])
        }

        return HandResult(rank: best.1, cards: sortCards(best.0))
    }

    /// Evaluates a single 5-card hand and determines its poker ranking.
    /// - Parameter cards: Exactly 5 cards
    /// - Returns: The `HandRank` that best describes the hand
    static func evaluateHand(_ cards: [Card]) -> HandRank {
        let rankCounts = countRanks(in: cards)

        let pairs = rankCounts.filter { $0.value == 2 }
        let trips = rankCounts.filter { $0.value == 3 }
        let quads = rankCounts.filter { $0.value == 4 }

        // Check for flush and straight combinations
        let suits = countSuits(in: cards)
        if let flushCards = suits.values.first(where: { $0.count >= 5 }) {
            let sortedFlush = sortCards(flushCards)
            if isStraight(sortedFlush) {
                return sortedFlush.first?.rank == "A" ? .royalFlush : .straightFlush
            }
            return .flush
        }

        if !quads.isEmpty {
            return .fourOfAKind
        } else if trips.count >= 2 {
            return .fullHouse
        } else if trips.count == 1 && pairs.count >= 1 {
            return .fullHouse
        } else if !trips.isEmpty {
            return .threeOfAKind
        } else if pairs.count == 2 {
            return .twoPair
        } else if pairs.count == 1 {
            return .onePair
        }

        return .highCard
    }

    // MARK: - Helper Functions

    /// Generates all possible combinations of a given size from an array.
    /// - Parameters:
    ///   - array: Source array
    ///   - k: Number of elements to choose
    /// - Returns: Array of combinations
    private static func combinations<T>(of array: [T], choosing k: Int) -> [[T]] {
        guard k > 0 else { return [[]] }
        guard let first = array.first else { return [] }

        let subcombos = combinations(of: Array(array.dropFirst()), choosing: k - 1)
        let withFirst = subcombos.map { [first] + $0 }
        let withoutFirst = combinations(of: Array(array.dropFirst()), choosing: k)

        return withFirst + withoutFirst
    }

    /// Counts the number of cards of each rank in the hand.
    /// - Parameter cards: A set of cards
    /// - Returns: Dictionary mapping ranks to their counts
    private static func countRanks(in cards: [Card]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for card in cards {
            counts[card.rank, default: 0] += 1
        }
        return counts
    }

    /// Groups cards by suit.
    /// - Parameter cards: A set of cards
    /// - Returns: Dictionary mapping suits to arrays of cards of that suit
    private static func countSuits(in cards: [Card]) -> [String: [Card]] {
        var suitDict: [String: [Card]] = [:]
        for card in cards {
            suitDict[card.suit, default: []].append(card)
        }
        return suitDict
    }

    /// Determines if the given set of cards forms a straight.
    /// - Parameter cards: Cards to check (should be sorted high-to-low)
    /// - Returns: `true` if the hand contains a straight
    private static func isStraight(_ cards: [Card]) -> Bool {
        let rankOrder = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        let uniqueRanks = Array(Set(cards.map { $0.rank }))
        let indices = uniqueRanks.compactMap { rankOrder.firstIndex(of: $0) }.sorted()

        // Check consecutive run of 5
        for i in 0..<(indices.count - 4) {
            if indices[i+4] - indices[i] == 4 {
                return true
            }
        }

        // Check for wheel (A-2-3-4-5)
        if Set(["A", "2", "3", "4", "5"]).isSubset(of: Set(uniqueRanks)) {
            return true
        }

        return false
    }

    /// Sorts cards in descending order based on rank strength.
    /// - Parameter cards: Unsorted card array
    /// - Returns: Cards sorted from high to low
    private static func sortCards(_ cards: [Card]) -> [Card] {
        let rankOrder = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        return cards.sorted {
            (rankOrder.firstIndex(of: $0.rank) ?? 0) > (rankOrder.firstIndex(of: $1.rank) ?? 0)
        }
    }
}
