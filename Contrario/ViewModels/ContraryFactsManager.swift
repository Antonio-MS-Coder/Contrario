import SwiftUI
import Foundation

class ContraryFactsManager: ObservableObject {
    // Type alias for category
    typealias Category = ContraryCategory
    
    @Published var facts: [ContraryFact] = []
    @Published var currentFact: ContraryFact?
    @Published var categories: [ContraryCategory] = []
    @Published var selectedCategory: String = "all"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasError = false
    
    private let loadingQueue = DispatchQueue(label: "contrario.loading", qos: .userInitiated)
    
    init() {
        // Load default facts synchronously for immediate display
        loadDefaultFacts()
        loadCategories() // Load categories immediately from default facts
        getRandomFact()
        
        // Load full facts asynchronously
        loadingQueue.async { [weak self] in
            self?.loadFactsAsync()
        }
    }
    
    func loadFacts() {
        isLoading = true
        errorMessage = nil
        hasError = false
        
        loadingQueue.async { [weak self] in
            self?.loadFactsAsync()
        }
    }
    
    private func loadFactsAsync() {
        // Load from bundled JSON file
        guard let url = Bundle.main.url(forResource: "contraryFacts", withExtension: "json") else {
            // If no JSON file, already have default facts loaded
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedFacts = try JSONDecoder().decode([ContraryFact].self, from: data)
            
            // Validate facts
            let validFacts = decodedFacts.filter { fact in
                !fact.text.isEmpty && 
                !fact.category.isEmpty &&
                fact.text.count <= 1000 && // Reasonable limit
                fact.contraryInsight.count <= 500 &&
                fact.source.count <= 200
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.facts = validFacts
                self.isLoading = false
                self.loadCategories()
                
                if self.facts.isEmpty {
                    print("Warning: No valid facts after validation")
                    self.loadDefaultFacts()
                }
            }
        } catch {
            print("Error decoding facts: \(error)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorMessage = "Failed to load facts. Using defaults."
                self.hasError = true
                self.isLoading = false
                // Default facts already loaded in init
            }
        }
    }
    
    func retryLoading() {
        loadFacts()
        loadCategories()
        getRandomFact()
    }
    
    func loadDefaultFacts() {
        facts = [
            ContraryFact(
                text: "The best startup ideas seem like bad ideas at first",
                category: "business",
                source: "Peter Thiel",
                contraryInsight: "If it were obviously good, someone would already be doing it"
            ),
            ContraryFact(
                text: "Competition is for losers",
                category: "business",
                source: "Zero to One",
                contraryInsight: "Monopolies drive progress by having resources to innovate"
            ),
            ContraryFact(
                text: "The most contrarian thing is not to oppose the crowd but to think for yourself",
                category: "philosophy",
                source: "Peter Thiel",
                contraryInsight: "True contrarianism isn't reflexive opposition"
            ),
            ContraryFact(
                text: "Moving fast and breaking things is often slower than being deliberate",
                category: "technology",
                source: "Contrarian Tech",
                contraryInsight: "Technical debt compounds faster than development speed"
            ),
            ContraryFact(
                text: "The best time to start a company is during a recession",
                category: "economics",
                source: "Startup Wisdom",
                contraryInsight: "Less competition, cheaper talent, and forced efficiency"
            ),
            ContraryFact(
                text: "Being first to market is overrated",
                category: "business",
                source: "Business Strategy",
                contraryInsight: "Being last can mean learning from everyone else's mistakes"
            ),
            ContraryFact(
                text: "Formal education can limit innovative thinking",
                category: "education",
                source: "Innovation Studies",
                contraryInsight: "Credentials create conformity; breakthroughs require unlearning"
            ),
            ContraryFact(
                text: "The sharing economy isn't about sharing",
                category: "economics",
                source: "Economic Analysis",
                contraryInsight: "It's about monetizing underutilized assets"
            ),
            ContraryFact(
                text: "Social networks make us less social",
                category: "society",
                source: "Digital Culture",
                contraryInsight: "Digital connections often replace deeper real relationships"
            ),
            ContraryFact(
                text: "AI won't replace humans, but humans using AI will replace those who don't",
                category: "future",
                source: "Tech Trends",
                contraryInsight: "The divide isn't human vs machine, but augmented vs unaugmented"
            ),
            ContraryFact(
                text: "Perfectionism is a form of procrastination",
                category: "philosophy",
                source: "Productivity Paradox",
                contraryInsight: "The pursuit of perfect prevents the achievement of good enough"
            ),
            ContraryFact(
                text: "Working harder is often less effective than working less",
                category: "business",
                source: "Productivity Research",
                contraryInsight: "Constraints force creativity and prevent burnout"
            ),
            ContraryFact(
                text: "The most valuable companies create new markets, not compete in existing ones",
                category: "innovation",
                source: "Blue Ocean Strategy",
                contraryInsight: "Competition validates markets but limits profits"
            ),
            ContraryFact(
                text: "Transparency can reduce trust",
                category: "society",
                source: "Organizational Psychology",
                contraryInsight: "Some ambiguity allows for benefit of the doubt"
            ),
            ContraryFact(
                text: "The best investment is often in what everyone else hates",
                category: "economics",
                source: "Contrarian Investing",
                contraryInsight: "Consensus creates overvaluation; pessimism creates opportunity"
            )
        ]
    }
    
    func loadCategories() {
        // Extract unique categories from facts
        let categorySet = Set(facts.map { $0.category })
        categories = categorySet.map { categoryKey in
            ContraryCategory(
                key: categoryKey,
                displayName: formatCategoryName(categoryKey),
                icon: getCategoryIcon(categoryKey),
                group: getCategoryGroup(categoryKey)
            )
        }.sorted { $0.displayName < $1.displayName }
    }
    
    func formatCategoryName(_ key: String) -> String {
        ContraryCategory.defaultDisplayName(for: key)
    }
    
    func getCategoryIcon(_ key: String) -> String {
        ContraryCategory.defaultIcon(for: key)
    }
    
    private func getCategoryGroup(_ key: String) -> CategoryGroup {
        ContraryCategory.defaultGroup(for: key)
    }
    
    func getRandomFact() {
        guard !facts.isEmpty else {
            errorMessage = "No facts available"
            hasError = true
            return
        }
        
        let filteredFacts = selectedCategory == "all" ? facts : facts.filter { $0.category == selectedCategory }
        
        if filteredFacts.isEmpty {
            // If no facts in selected category, reset to all
            selectedCategory = "all"
            currentFact = facts.randomElement()
        } else {
            // Try to get a different fact than current (with safety limit)
            if let current = currentFact, filteredFacts.count > 1 {
                var attempts = 0
                var newFact = filteredFacts.randomElement()
                while newFact?.id == current.id && attempts < 10 {
                    newFact = filteredFacts.randomElement()
                    attempts += 1
                }
                currentFact = newFact
            } else {
                currentFact = filteredFacts.randomElement()
            }
        }
        
        hasError = false
        errorMessage = nil
    }
    
    func getFactsForCategory(_ category: String) -> [ContraryFact] {
        return facts.filter { $0.category == category }
    }
}