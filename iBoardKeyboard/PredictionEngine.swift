//
//  PredictionEngine.swift
//  iBoardKeyboard
//

import UIKit

class PredictionEngine {
    
    static let shared = PredictionEngine()
    
    private var wordFrequency: [String: Int] = [:]
    private var commonWords: [String] = []
    private var contactNames: [String] = []
    private var contactEmails: [String] = []
    private var contactPhones: [String] = []
    
    private init() {
        loadCommonWords()
    }
    
    private func loadCommonWords() {
        // Common English words for basic prediction
        commonWords = [
            "the", "be", "to", "of", "and", "a", "in", "that", "have", "I",
            "it", "for", "not", "on", "with", "he", "as", "you", "do", "at",
            "this", "but", "his", "by", "from", "they", "we", "say", "her", "she",
            "or", "an", "will", "my", "one", "all", "would", "there", "their", "what",
            "so", "up", "out", "if", "about", "who", "get", "which", "go", "me",
            "when", "make", "can", "like", "time", "no", "just", "him", "know", "take",
            "people", "into", "year", "your", "good", "some", "could", "them", "see", "other",
            "than", "then", "now", "look", "only", "come", "its", "over", "think", "also",
            "back", "after", "use", "two", "how", "our", "work", "first", "well", "way",
            "even", "new", "want", "because", "any", "these", "give", "day", "most", "us"
        ]
    }
    
    func updateContacts(names: [String], emails: [String], phones: [String]) {
        self.contactNames = names
        self.contactEmails = emails
        self.contactPhones = phones
    }
    
    func getPredictions(for text: String, context: String? = nil) -> [String] {
        guard !text.isEmpty else { return [] }
        
        var predictions: [String] = []
        
        // Get word predictions
        let wordPredictions = getWordPredictions(for: text)
        predictions.append(contentsOf: wordPredictions)
        
        // Get contact predictions if enabled
        if UserDefaultsManager.shared.enableContactPredictions {
            let contactPredictions = getContactPredictions(for: text)
            predictions.append(contentsOf: contactPredictions)
        }
        
        // Remove duplicates and limit to 3
        predictions = Array(Set(predictions)).prefix(3).map { $0 }
        
        // Sort by relevance (frequency and length)
        predictions.sort { word1, word2 in
            let freq1 = wordFrequency[word1.lowercased()] ?? 0
            let freq2 = wordFrequency[word2.lowercased()] ?? 0
            
            if freq1 != freq2 {
                return freq1 > freq2
            }
            
            return word1.count < word2.count
        }
        
        return predictions
    }
    
    private func getWordPredictions(for text: String) -> [String] {
        let lowercasedText = text.lowercased()
        
        // Filter common words that start with the input
        let matches = commonWords.filter { $0.hasPrefix(lowercasedText) }
        
        // If input is capitalized, capitalize predictions
        let shouldCapitalize = text.first?.isUppercase ?? false
        
        return matches.map { word in
            if shouldCapitalize {
                return word.capitalized
            }
            return word
        }
    }
    
    private func getContactPredictions(for text: String) -> [String] {
        var predictions: [String] = []
        let lowercasedText = text.lowercased()
        
        // Check for email pattern (contains @)
        if text.contains("@") {
            let emailMatches = contactEmails.filter { $0.lowercased().hasPrefix(lowercasedText) }
            predictions.append(contentsOf: emailMatches.prefix(2))
        }
        
        // Check for phone number pattern (starts with digit or +)
        else if text.first?.isNumber ?? false || text.hasPrefix("+") {
            let phoneMatches = contactPhones.filter { $0.hasPrefix(text) }
            predictions.append(contentsOf: phoneMatches.prefix(2))
        }
        
        // Otherwise check names
        else {
            let nameMatches = contactNames.filter { $0.lowercased().hasPrefix(lowercasedText) }
            predictions.append(contentsOf: nameMatches.prefix(2))
        }
        
        return predictions
    }
    
    func learnWord(_ word: String) {
        let lowercased = word.lowercased()
        wordFrequency[lowercased, default: 0] += 1
        
        // Add to common words if frequently used
        if wordFrequency[lowercased, default: 0] > 5 && !commonWords.contains(lowercased) {
            commonWords.append(lowercased)
        }
    }
    
    func getNextWordPredictions(after word: String) -> [String] {
        // Simple bigram predictions
        let lowercased = word.lowercased()
        
        switch lowercased {
        case "i":
            return ["am", "have", "will"]
        case "you":
            return ["are", "have", "will"]
        case "the":
            return ["first", "best", "most"]
        case "to":
            return ["be", "do", "go"]
        case "a":
            return ["lot", "few", "bit"]
        default:
            return []
        }
    }
}
