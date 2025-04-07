//
//  HandEvaluator.swift
//  PokerPlayground
//
//  Created by Omar Ahmad on 4/7/25.
//


import Foundation

struct HandEvaluator {    
    static func evaluateHand(_ cards: [Card]) -> HandRank {
        let rankCounts = countRanks(in: cards)

        let pairs = rankCounts.filter { $0.value == 2 }
        let trips = rankCounts.filter { $0.value == 3 }
        let quads = rankCounts.filter { $0.value == 4 }

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
            return .fullHouse //not sure?
        }
        else if !trips.isEmpty && !pairs.isEmpty {
            return .fullHouse //not sure if still needed? 
        } else if !trips.isEmpty {
            return .threeOfAKind
        } else if pairs.count == 2 {
            return .twoPair
        } else if pairs.count == 1 {
            return .onePair
        }

        return .highCard
    }
    
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

    private static func combinations<T>(of array: [T], choosing k: Int) -> [[T]] {
        guard k > 0 else { return [[]] }
        guard let first = array.first else { return [] }

        let subcombos = combinations(of: Array(array.dropFirst()), choosing: k - 1)
        var withFirst = subcombos.map { [first] + $0 }
        let withoutFirst = combinations(of: Array(array.dropFirst()), choosing: k)

        return withFirst + withoutFirst
    }
    
    private static func countRanks(in cards: [Card]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for card in cards {
            counts[card.rank, default: 0] += 1
        }
        return counts
    }
    
    private static func countSuits(in cards: [Card]) -> [String: [Card]] {
        var suitDict: [String: [Card]] = [:]
        for card in cards {
            suitDict[card.suit, default: []].append(card)
        }
        return suitDict
    }
    
    private static func isStraight(_ cards: [Card]) -> Bool {
        let rankOrder = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        let uniqueRanks = Array(Set(cards.map { $0.rank }))
        let indices = uniqueRanks.compactMap { rankOrder.firstIndex(of: $0) }.sorted()

        for i in 0..<(indices.count - 4) {
            if indices[i+4] - indices[i] == 4 {
                return true
            }
        }

        // Handle wheel straight (A-2-3-4-5)
        if Set(["A", "2", "3", "4", "5"]).isSubset(of: Set(uniqueRanks)) {
            return true
        }

        return false
    }
    
    private static func sortCards(_ cards: [Card]) -> [Card] {
        let rankOrder = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        return cards.sorted {
            rankOrder.firstIndex(of: $0.rank)! > rankOrder.firstIndex(of: $1.rank)!
        }
    }
}
