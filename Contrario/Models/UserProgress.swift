import Foundation
import SwiftUI

// MARK: - User Progress Model
struct UserProgress: Codable {
    var discoveredFacts: Set<String> = []
    var categoryProgress: [String: CategoryProgress] = [:]
    var lastAccessDate: Date = Date()
    var totalDiscovered: Int {
        discoveredFacts.count
    }
    
    mutating func markFactAsDiscovered(_ factId: String, category: String) {
        discoveredFacts.insert(factId)
        
        if categoryProgress[category] == nil {
            categoryProgress[category] = CategoryProgress()
        }
        categoryProgress[category]?.discoveredFactIds.insert(factId)
        categoryProgress[category]?.lastAccessDate = Date()
    }
    
    func getProgressForCategory(_ category: String, totalFacts: Int) -> (discovered: Int, total: Int) {
        let discovered = categoryProgress[category]?.discoveredFactIds.count ?? 0
        return (discovered, totalFacts)
    }
    
    func getCategoryState(_ category: String, totalFacts: Int) -> CategoryState {
        let discovered = categoryProgress[category]?.discoveredFactIds.count ?? 0
        
        if discovered == 0 {
            return .locked
        } else if discovered == totalFacts {
            return .completed
        } else {
            return .inProgress(discovered, totalFacts)
        }
    }
}

// MARK: - Category Progress
struct CategoryProgress: Codable {
    var discoveredFactIds: Set<String> = []
    var lastAccessDate: Date = Date()
    var isUnlocked: Bool = true
}

// MARK: - Category State
enum CategoryState {
    case locked
    case inProgress(Int, Int) // (discovered, total)
    case completed
    
    var progressColor: Color {
        switch self {
        case .locked:
            return .gray
        case .inProgress:
            return .orange
        case .completed:
            return .green
        }
    }
    
    var isAccessible: Bool {
        switch self {
        case .locked:
            return false
        default:
            return true
        }
    }
}

// MARK: - Enhanced Category Model
struct EnhancedCategory {
    let base: ContraryCategory
    let description: String
    let tagline: String
    let difficulty: Difficulty
    let estimatedMinutes: Int
    let color: Color
    
    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var icon: String {
            switch self {
            case .beginner: return "star"
            case .intermediate: return "star.leadinghalf.filled"
            case .advanced: return "star.fill"
            }
        }
    }
    
    static func getCategoryMetadata(for key: String) -> EnhancedCategory? {
        let metadata: [String: (description: String, tagline: String, difficulty: Difficulty, minutes: Int, color: Color)] = [
            "business": (
                "Explore unconventional business wisdom and startup contrarian truths",
                "Where disruption is born",
                .intermediate,
                15,
                Color(red: 0.91, green: 0.12, blue: 0.39) // Pink/Red
            ),
            "economics": (
                "Discover the hidden mechanics of money, markets, and economic systems",
                "Money's hidden mechanics",
                .advanced,
                20,
                Color(red: 0.95, green: 0.77, blue: 0.06) // Yellow
            ),
            "education": (
                "Uncover the secret failures and unspoken truths of learning systems",
                "Learning's secret failures",
                .beginner,
                10,
                Color(red: 0.29, green: 0.33, blue: 0.41) // Dark gray
            ),
            "future": (
                "Challenge conventional predictions about tomorrow's world",
                "Tomorrow's contrarian views",
                .intermediate,
                15,
                Color(red: 0.58, green: 0.42, blue: 0.94) // Purple
            ),
            "technology": (
                "Question the tech industry's accepted truths and hidden assumptions",
                "Tech's unspoken truths",
                .intermediate,
                15,
                Color(red: 0.26, green: 0.62, blue: 0.95) // Blue
            ),
            "society": (
                "Examine society's comfortable lies and uncomfortable truths",
                "Culture's hidden patterns",
                .beginner,
                12,
                Color(red: 0.95, green: 0.42, blue: 0.26) // Orange
            ),
            "philosophy": (
                "Challenge fundamental assumptions about existence and meaning",
                "Reality's edge cases",
                .advanced,
                25,
                Color(red: 0.42, green: 0.26, blue: 0.95) // Deep purple
            ),
            "innovation": (
                "Discover why most innovations fail and what really drives change",
                "Beyond the hype cycle",
                .intermediate,
                18,
                Color(red: 0.26, green: 0.95, blue: 0.62) // Green
            ),
            "politics": (
                "Uncover the incentives and systems behind political theater",
                "Power's true mechanics",
                .advanced,
                22,
                Color(red: 0.75, green: 0.22, blue: 0.17) // Dark red
            )
        ]
        
        guard let category = ContraryCategory.allCategories.first(where: { $0.key == key }),
              let meta = metadata[key] else {
            return nil
        }
        
        return EnhancedCategory(
            base: category,
            description: meta.description,
            tagline: meta.tagline,
            difficulty: meta.difficulty,
            estimatedMinutes: meta.minutes,
            color: meta.color
        )
    }
}