import Foundation

enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let hasLaunchedBefore = "hasLaunchedBefore"
    static let isDarkMode = "isDarkMode"
    static let notificationsEnabled = "notificationsEnabled"
    static let dailyFactTime = "dailyFactTime"
    static let favoritesFacts = "favoritesFacts"
    static let intellectualStreakCount = "intellectualStreakCount"
    static let lastIntellectualAccess = "lastIntellectualAccess"
    
    // Category tracking keys
    static func viewedFacts(for category: String) -> String {
        return "viewed_facts_\(category)"
    }
    
    static func lastVisited(for category: String) -> String {
        return "last_visited_\(category)"
    }
}