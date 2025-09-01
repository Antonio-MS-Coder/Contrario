import Foundation
import SwiftUI

// MARK: - User Progress Model
struct UserProgress: Codable {
    var discoveredFacts: Set<String> = []
    var categoryProgress: [String: CategoryProgress] = [:]
    var lastAccessDate: Date = Date()
    var lastDiscoveryDate: Date?
    
    var totalDiscovered: Int {
        discoveredFacts.count
    }
    
    // Nested CategoryProgress type
    struct CategoryProgress: Codable {
        var discoveredFactIds: Set<String> = []
        var lastAccessDate: Date = Date()
        var isUnlocked: Bool = true
        
        var discovered: Int {
            discoveredFactIds.count
        }
    }
    
    mutating func markFactAsDiscovered(_ factId: String, category: String) {
        discoveredFacts.insert(factId)
        
        if categoryProgress[category] == nil {
            categoryProgress[category] = CategoryProgress()
        }
        categoryProgress[category]?.discoveredFactIds.insert(factId)
        categoryProgress[category]?.lastAccessDate = Date()
        lastDiscoveryDate = Date()
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
    let base: ContraryFactsManager.Category
    let icon: String
    let color: Color
    let description: String
    
    static func getCategoryMetadata(for key: String) -> EnhancedCategory? {
        guard let category = ContraryFactsManager.Category.allCategories.first(where: { $0.key == key }) else {
            return nil
        }
        
        let metadata: (icon: String, color: Color, description: String) = {
            switch key {
            case "technology":
                return ("💻", Color.blue, "Challenge Silicon Valley's gospel")
            case "business":
                return ("💼", Color.green, "Question corporate orthodoxy")
            case "psychology":
                return ("🧠", Color.purple, "Explore the mind's contradictions")
            case "society":
                return ("🏛️", Color.orange, "Examine social assumptions")
            case "history":
                return ("📜", Color.brown, "Uncover forgotten narratives")
            case "science":
                return ("🔬", Color.cyan, "Question scientific dogma")
            case "philosophy":
                return ("💭", Color.indigo, "Challenge fundamental beliefs")
            case "health":
                return ("💊", Color.red, "Rethink wellness wisdom")
            default:
                return ("❓", Color.gray, "Explore the unknown")
            }
        }()
        
        return EnhancedCategory(
            base: category,
            icon: metadata.icon,
            color: metadata.color,
            description: metadata.description
        )
    }
}