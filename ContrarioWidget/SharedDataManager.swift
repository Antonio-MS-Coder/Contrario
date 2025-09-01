import Foundation

struct SharedDataManager {
    static let appGroupIdentifier = "group.com.lck.Contrario"
    static let dailyFactKey = "dailyFact"
    static let dailyFactDateKey = "dailyFactDate"
    static let dailyFactCategoryKey = "dailyFactCategory"
    static let dailyFactInsightKey = "dailyFactInsight"
    static let dailyFactSourceKey = "dailyFactSource"
    
    static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    static func getDailyFact() -> (text: String, category: String, insight: String, source: String, date: Date)? {
        guard let defaults = sharedDefaults,
              let text = defaults.string(forKey: dailyFactKey),
              let category = defaults.string(forKey: dailyFactCategoryKey),
              let date = defaults.object(forKey: dailyFactDateKey) as? Date else {
            return nil
        }
        
        let insight = defaults.string(forKey: dailyFactInsightKey) ?? ""
        let source = defaults.string(forKey: dailyFactSourceKey) ?? ""
        
        return (text: text, category: category, insight: insight, source: source, date: date)
    }
    
    static func saveDailyFact(text: String, category: String, insight: String, source: String) {
        guard let defaults = sharedDefaults else { return }
        
        defaults.set(text, forKey: dailyFactKey)
        defaults.set(category, forKey: dailyFactCategoryKey)
        defaults.set(insight, forKey: dailyFactInsightKey)
        defaults.set(source, forKey: dailyFactSourceKey)
        defaults.set(Date(), forKey: dailyFactDateKey)
    }
    
    static func isDarkMode() -> Bool {
        return sharedDefaults?.bool(forKey: "isDarkMode") ?? false
    }
    
    static func saveDarkMode(_ isDarkMode: Bool) {
        sharedDefaults?.set(isDarkMode, forKey: "isDarkMode")
    }
}