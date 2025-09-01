import Foundation
import SwiftUI

class UserProgressManager: ObservableObject {
    @Published var userProgress: UserProgress
    private let userDefaults = UserDefaults.standard
    private let progressKey = "userProgressData"
    
    init() {
        // Load saved progress or create new
        if let data = userDefaults.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.userProgress = decoded
        } else {
            self.userProgress = UserProgress()
        }
    }
    
    func markFactAsDiscovered(_ fact: ContraryFact) {
        userProgress.markFactAsDiscovered(fact.id, category: fact.category)
        saveProgress()
    }
    
    func getCategoryProgress(_ category: String, totalFacts: Int) -> (discovered: Int, total: Int) {
        return userProgress.getProgressForCategory(category, totalFacts: totalFacts)
    }
    
    func getCategoryState(_ category: String, totalFacts: Int) -> CategoryState {
        return userProgress.getCategoryState(category, totalFacts: totalFacts)
    }
    
    func getOverallProgress(totalFacts: Int) -> Double {
        guard totalFacts > 0 else { return 0 }
        return Double(userProgress.totalDiscovered) / Double(totalFacts)
    }
    
    func getTotalCategoriesWithProgress() -> Int {
        return userProgress.categoryProgress.filter { !$0.value.discoveredFactIds.isEmpty }.count
    }
    
    func getCategoryProgress(for category: String) -> UserProgress.CategoryProgress? {
        return userProgress.categoryProgress[category]
    }
    
    func getExploredCategories() -> [String] {
        return userProgress.categoryProgress
            .filter { !$0.value.discoveredFactIds.isEmpty }
            .map { $0.key }
    }
    
    func isFactDiscovered(_ factId: String) -> Bool {
        return userProgress.discoveredFacts.contains(factId)
    }
    
    func resetProgress() {
        userProgress = UserProgress()
        saveProgress()
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
}