import SwiftUI

// MARK: - Supporting Types

enum ExploreViewMode: String, CaseIterable {
    case categories = "Categories"
    case beliefsTracker = "Belief Evolution" 
    case synthesis = "Wisdom Synthesis"
    
    var icon: String {
        switch self {
        case .categories: return "square.grid.2x2.fill"
        case .beliefsTracker: return "brain.head.profile"
        case .synthesis: return "network"
        }
    }
    
    var description: String {
        switch self {
        case .categories: return "Explore knowledge territories"
        case .beliefsTracker: return "Track your evolving beliefs"
        case .synthesis: return "Connect ideas across domains"
        }
    }
}

// MARK: - Enhanced Header

struct ExploreHeader: View {
    @Binding var viewMode: ExploreViewMode
    let onKnowledgeGraphTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and graph button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EXPLORE")
                        .font(.system(size: 32, weight: .heavy, design: .default))
                        .foregroundColor(.white)
                        .tracking(1.5)
                    
                    Text(viewMode.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: onKnowledgeGraphTap) {
                    VStack(spacing: 4) {
                        Image(systemName: "network")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                        
                        Text("Graph")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.95, green: 0.77, blue: 0.06), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Mode selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ExploreViewMode.allCases, id: \.self) { mode in
                        ModeButton(
                            mode: mode,
                            isSelected: viewMode == mode
                        ) {
                            viewMode = mode
                            HapticManager.shared.impact(style: .light)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 12)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
}

struct ModeButton: View {
    let mode: ExploreViewMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 14))
                
                Text(mode.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? Color(red: 0.16, green: 0.11, blue: 0.29) : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? .white : Color.white.opacity(0.15))
            )
        }
    }
}

// MARK: - Content Views

struct CategoriesContent: View {
    let factsManager: ContraryFactsManager
    let progressManager: UserProgressManager
    @Binding var selectedCategory: String?
    @Binding var showCategoryDetail: Bool
    let categoriesWithProgress: Int
    let totalCategories: Int
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Progress Card
                ProgressCard(
                    categoriesDiscovered: categoriesWithProgress,
                    totalCategories: totalCategories,
                    progressManager: progressManager,
                    totalFacts: factsManager.facts.count
                )
                .padding(.horizontal)
                
                // Categories Grid
                CategoriesGrid(
                    categories: factsManager.categories,
                    factsManager: factsManager,
                    progressManager: progressManager,
                    selectedCategory: $selectedCategory,
                    showCategoryDetail: $showCategoryDetail
                )
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}

struct BeliefTrackerContent: View {
    let beliefTracker: BeliefEvolutionTracker
    let progressManager: UserProgressManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Belief evolution summary
                BeliefEvolutionSummary(beliefTracker: beliefTracker)
                    .padding(.horizontal)
                
                // Recent belief changes
                if !beliefTracker.recentChanges.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RECENT BELIEF CHANGES")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                            .tracking(0.5)
                            .padding(.horizontal)
                        
                        ForEach(beliefTracker.recentChanges, id: \.id) { change in
                            BeliefChangeCard(change: change)
                                .padding(.horizontal)
                        }
                    }
                }
                
                // Knowledge graph teaser
                KnowledgeGraphTeaser()
                    .padding(.horizontal)
                    .padding(.bottom, 30)
            }
        }
    }
}

struct WisdomSynthesisContent: View {
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Synthesis overview
                WisdomSynthesisOverview(
                    totalDiscovered: progressManager.userProgress.totalDiscovered,
                    categoriesExplored: progressManager.getTotalCategoriesWithProgress()
                )
                .padding(.horizontal)
                
                // Pattern insights
                if progressManager.userProgress.totalDiscovered >= 10 {
                    PatternInsightsCard(
                        progressManager: progressManager,
                        factsManager: factsManager
                    )
                    .padding(.horizontal)
                }
                
                // Cross-category connections
                CrossCategoryConnections(
                    progressManager: progressManager,
                    factsManager: factsManager
                )
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Belief Tracking Components

struct BeliefEvolutionSummary: View {
    let beliefTracker: BeliefEvolutionTracker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("YOUR BELIEF EVOLUTION")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                BeliefMetric(
                    title: "Beliefs Tracked",
                    value: "\(beliefTracker.trackedBeliefs.count)",
                    icon: "brain.head.profile"
                )
                
                BeliefMetric(
                    title: "Changes Made",
                    value: "\(beliefTracker.totalChanges)",
                    icon: "arrow.triangle.2.circlepath"
                )
            }
            
            Text("Track how your beliefs evolve as you discover contrarian insights")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct BeliefMetric: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct BeliefChangeCard: View {
    let change: BeliefChange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(change.category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    .tracking(0.5)
                
                Spacer()
                
                Text(change.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Before")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(change.beforeBelief)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("After")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(change.afterBelief)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct KnowledgeGraphTeaser: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "network")
                .font(.system(size: 32))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
            
            Text("Visualize Your Knowledge Network")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text("See how your beliefs connect across different domains")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Wisdom Synthesis Components

struct WisdomSynthesisOverview: View {
    let totalDiscovered: Int
    let categoriesExplored: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WISDOM SYNTHESIS")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text("Connecting patterns across \(categoriesExplored) knowledge domains")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 20) {
                SynthesisMetric(
                    title: "Facts Discovered",
                    value: "\(totalDiscovered)",
                    icon: "lightbulb.fill"
                )
                
                SynthesisMetric(
                    title: "Domains",
                    value: "\(categoriesExplored)",
                    icon: "squares.below.rectangle"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct SynthesisMetric: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct PatternInsightsCard: View {
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EMERGING PATTERNS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                .tracking(0.5)
            
            VStack(alignment: .leading, spacing: 8) {
                PatternInsight(
                    title: "Centralized vs Decentralized",
                    description: "You've discovered contrarian views about power structures across business, technology, and society."
                )
                
                PatternInsight(
                    title: "Short-term vs Long-term",
                    description: "A recurring theme in your exploration challenges short-sighted thinking."
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct PatternInsight: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct CrossCategoryConnections: View {
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CROSS-DOMAIN CONNECTIONS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                .tracking(0.5)
            
            Text("Similar contrarian principles appear across different knowledge areas:")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 8) {
                ConnectionLine(
                    category1: "Business",
                    category2: "Philosophy",
                    connection: "Question conventional wisdom"
                )
                
                ConnectionLine(
                    category1: "Technology", 
                    category2: "Society",
                    connection: "Unintended consequences"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ConnectionLine: View {
    let category1: String
    let category2: String
    let connection: String
    
    var body: some View {
        HStack {
            Text(category1)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                )
            
            Text("↔")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
            
            Text(category2)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                )
            
            Spacer()
            
            Text(connection)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Supporting Models

struct BeliefChange: Identifiable {
    let id = UUID()
    let category: String
    let beforeBelief: String
    let afterBelief: String
    let triggeringFact: String
    let date: Date
}

class BeliefEvolutionTracker: ObservableObject {
    @Published var trackedBeliefs: [String: String] = [:]
    @Published var recentChanges: [BeliefChange] = []
    
    var totalChanges: Int {
        recentChanges.count
    }
    
    func recordBeliefChange(
        category: String,
        before: String,
        after: String,
        triggeringFact: String
    ) {
        let change = BeliefChange(
            category: category,
            beforeBelief: before,
            afterBelief: after,
            triggeringFact: triggeringFact,
            date: Date()
        )
        
        recentChanges.insert(change, at: 0)
        if recentChanges.count > 10 {
            recentChanges = Array(recentChanges.prefix(10))
        }
        
        trackedBeliefs[category] = after
    }
}

// MARK: - Knowledge Graph View

struct KnowledgeGraphView: View {
    let factsManager: ContraryFactsManager
    let progressManager: UserProgressManager
    let beliefTracker: BeliefEvolutionTracker
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.16, green: 0.11, blue: 0.29)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Graph visualization placeholder
                        KnowledgeGraphVisualization(
                            progressManager: progressManager,
                            factsManager: factsManager
                        )
                        .padding()
                        
                        // Graph insights
                        GraphInsights(
                            beliefTracker: beliefTracker,
                            progressManager: progressManager
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Knowledge Graph")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct KnowledgeGraphVisualization: View {
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("YOUR KNOWLEDGE NETWORK")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            // Simplified graph visualization
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 300)
                
                // Node placeholder visualization
                GeometryReader { geometry in
                    ForEach(0..<factsManager.categories.count, id: \.self) { index in
                        let category = factsManager.categories[index]
                        let angle = Double(index) * 2 * .pi / Double(factsManager.categories.count)
                        let radius = min(geometry.size.width, geometry.size.height) * 0.3
                        let x = geometry.size.width/2 + cos(angle) * radius
                        let y = geometry.size.height/2 + sin(angle) * radius
                        
                        GraphNode(
                            category: category,
                            progress: progressManager.getCategoryProgress(category.key, totalFacts: factsManager.getFactsForCategory(category.key).count)
                        )
                        .position(x: x, y: y)
                    }
                }
            }
            .frame(height: 300)
        }
    }
}

struct GraphNode: View {
    let category: ContraryCategory
    let progress: (discovered: Int, total: Int)
    
    var completion: Double {
        guard progress.total > 0 else { return 0 }
        return Double(progress.discovered) / Double(progress.total)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2 + completion * 0.8))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                )
            
            Text(category.displayName.prefix(8))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct GraphInsights: View {
    let beliefTracker: BeliefEvolutionTracker
    let progressManager: UserProgressManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GRAPH INSIGHTS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                GraphInsightItem(
                    icon: "arrow.branch",
                    title: "Most Connected Domain",
                    value: "Philosophy - links to 4 other areas"
                )
                
                GraphInsightItem(
                    icon: "bolt.fill",
                    title: "Strongest Belief Change",
                    value: "Business assumptions → contrarian strategies"
                )
                
                GraphInsightItem(
                    icon: "network",
                    title: "Knowledge Density",
                    value: "\(progressManager.userProgress.totalDiscovered) insights across \(progressManager.getTotalCategoriesWithProgress()) domains"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct GraphInsightItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}