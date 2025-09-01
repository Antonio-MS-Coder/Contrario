import Foundation

struct ContraryFact: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let category: String
    let source: String
    let contraryInsight: String
    
    init(id: String? = nil, text: String, category: String, source: String = "", contraryInsight: String = "") {
        // Create deterministic ID based on content if not provided
        self.id = id ?? "\(text.prefix(50))-\(category)".data(using: .utf8)!.base64EncodedString()
        self.text = text
        self.category = category
        self.source = source
        self.contraryInsight = contraryInsight
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case category
        case source
        case contraryInsight
    }
}

struct ContraryCategory: Hashable, Equatable {
    let key: String
    let displayName: String
    let icon: String
    let group: CategoryGroup
    
    static var allCategories: [ContraryCategory] = []
    
    static func loadFromJSON() {
        guard let url = Bundle.main.url(forResource: "contraryFacts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonFacts = try? JSONDecoder().decode([ContraryFact].self, from: data) else {
            return
        }
        
        var categories: [ContraryCategory] = []
        let categoryKeys = Set(jsonFacts.map { $0.category })
        
        for key in categoryKeys {
            let category = ContraryCategory(
                key: key,
                displayName: defaultDisplayName(for: key),
                icon: defaultIcon(for: key),
                group: defaultGroup(for: key)
            )
            categories.append(category)
        }
        
        allCategories = categories.sorted { $0.displayName < $1.displayName }
    }
    
    static func defaultDisplayName(for key: String) -> String {
        let defaults: [String: String] = [
            "business": "Business & Startups",
            "technology": "Technology",
            "society": "Society & Culture",
            "economics": "Economics",
            "education": "Education",
            "philosophy": "Philosophy",
            "innovation": "Innovation",
            "politics": "Politics",
            "future": "Future Trends"
        ]
        return defaults[key] ?? key.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    static func defaultIcon(for key: String) -> String {
        let defaults: [String: String] = [
            "business": "briefcase.fill",
            "technology": "cpu",
            "society": "person.3.fill",
            "economics": "chart.line.uptrend.xyaxis",
            "education": "graduationcap.fill",
            "philosophy": "brain",
            "innovation": "lightbulb.fill",
            "politics": "building.columns.fill",
            "future": "arrow.forward.circle.fill"
        ]
        return defaults[key] ?? "star.circle"
    }
    
    static func defaultGroup(for key: String) -> CategoryGroup {
        let business = ["business", "economics", "innovation"]
        let thinking = ["philosophy", "education", "future"]
        let social = ["society", "politics"]
        let tech = ["technology"]
        
        if business.contains(key) {
            return .business
        } else if thinking.contains(key) {
            return .thinking
        } else if social.contains(key) {
            return .social
        } else if tech.contains(key) {
            return .technology
        } else {
            return .otros
        }
    }
}

enum CategoryGroup: String, CaseIterable {
    case business = "Business & Innovation"
    case thinking = "Philosophy & Thinking"
    case social = "Society & Politics"
    case technology = "Technology"
    case otros = "Other"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .business: return "briefcase.fill"
        case .thinking: return "brain"
        case .social: return "person.3.fill"
        case .technology: return "cpu"
        case .otros: return "folder"
        }
    }
    
    var categories: [ContraryCategory] {
        ContraryCategory.allCategories.filter { $0.group == self }
    }
}