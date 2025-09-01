import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var factsManager: ContraryFactsManager
    @StateObject private var progressManager = UserProgressManager()
    @StateObject private var beliefTracker = BeliefEvolutionTracker()
    @State private var selectedCategory: String?
    @State private var showCategoryDetail = false
    @State private var showKnowledgeGraph = false
    @State private var viewMode: ExploreViewMode = .discover
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Progressive feature unlocking
    var availableModes: [ExploreViewMode] {
        var modes: [ExploreViewMode] = [.discover]
        
        if progressManager.userProgress.totalDiscovered >= 5 {
            modes.append(.journey)
        }
        
        if progressManager.userProgress.totalDiscovered >= 15 {
            modes.append(.insights)
        }
        
        return modes
    }
    
    var totalCategories: Int {
        factsManager.categories.count
    }
    
    var categoriesWithProgress: Int {
        progressManager.getTotalCategoriesWithProgress()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color("BackgroundGradientStart"),
                        Color("BackgroundGradientEnd")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced header with progressive tabs
                    ExploreHeader(
                        viewMode: $viewMode,
                        availableModes: availableModes,
                        totalDiscovered: progressManager.userProgress.totalDiscovered,
                        onKnowledgeGraphTap: {
                            showKnowledgeGraph = true
                        }
                    )
                    
                    // Content based on view mode
                    ScrollView {
                        switch viewMode {
                        case .discover:
                            DiscoverContent(
                                factsManager: factsManager,
                                progressManager: progressManager,
                                selectedCategory: $selectedCategory,
                                showCategoryDetail: $showCategoryDetail,
                                categoriesWithProgress: categoriesWithProgress,
                                totalCategories: totalCategories
                            )
                        
                        case .journey:
                            JourneyContent(
                                beliefTracker: beliefTracker,
                                progressManager: progressManager,
                                factsManager: factsManager
                            )
                        
                        case .insights:
                            InsightsContent(
                                progressManager: progressManager,
                                factsManager: factsManager
                            )
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCategoryDetail) {
                if let category = selectedCategory,
                   let enhanced = EnhancedCategory.getCategoryMetadata(for: category) {
                    CategoryDetailView(
                        enhanced: enhanced,
                        facts: factsManager.getFactsForCategory(category),
                        progressManager: progressManager,
                        factsManager: factsManager
                    )
                }
            }
            .sheet(isPresented: $showKnowledgeGraph) {
                KnowledgeGraphView(
                    factsManager: factsManager,
                    progressManager: progressManager,
                    beliefTracker: beliefTracker
                )
            }
        }
        .environmentObject(progressManager)
    }
}

// MARK: - Explore View Mode
enum ExploreViewMode: String, CaseIterable {
    case discover = "Discover"
    case journey = "My Journey"
    case insights = "Connections"
    
    var icon: String {
        switch self {
        case .discover: return "magnifyingglass"
        case .journey: return "chart.line.uptrend.xyaxis"
        case .insights: return "brain.head.profile"
        }
    }
    
    var description: String {
        switch self {
        case .discover: return "Find contrarian facts by topic"
        case .journey: return "Track your intellectual evolution"
        case .insights: return "Discover patterns in your learning"
        }
    }
    
    var unlockMessage: String {
        switch self {
        case .discover: return ""
        case .journey: return "Discover 5 facts to unlock"
        case .insights: return "Discover 15 facts to unlock"
        }
    }
    
    var requiredFacts: Int {
        switch self {
        case .discover: return 0
        case .journey: return 5
        case .insights: return 15
        }
    }
}

// MARK: - Enhanced Header
struct ExploreHeader: View {
    @Binding var viewMode: ExploreViewMode
    let availableModes: [ExploreViewMode]
    let totalDiscovered: Int
    let onKnowledgeGraphTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and graph button
            HStack {
                Text("EXPLORE")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("PrimaryText"))
                    .tracking(1.5)
                
                Spacer()
                
                // Knowledge graph button (unlock at 10 facts)
                Button(action: onKnowledgeGraphTap) {
                    Image(systemName: "network")
                        .font(.system(size: 20))
                        .foregroundColor(totalDiscovered >= 10 ? Color(red: 0.95, green: 0.77, blue: 0.06) : Color("SecondaryText"))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(totalDiscovered >= 10 ? Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2) : Color("CardBackground"))
                        )
                }
                .disabled(totalDiscovered < 10)
            }
            .padding(.horizontal)
            
            // Subtitle
            Text("Track your evolving beliefs")
                .font(.system(size: 14))
                .foregroundColor(Color("SubtitleText"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Progressive tabs
            HStack(spacing: 0) {
                ForEach(ExploreViewMode.allCases, id: \.self) { mode in
                    TabButton(
                        mode: mode,
                        isSelected: viewMode == mode,
                        isLocked: !availableModes.contains(mode),
                        totalDiscovered: totalDiscovered
                    ) {
                        if availableModes.contains(mode) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewMode = mode
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 60)
        .background(
            Color("CardBackground").opacity(0.3)
                .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let mode: ExploreViewMode
    let isSelected: Bool
    let isLocked: Bool
    let totalDiscovered: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: mode.icon)
                        .font(.system(size: 14))
                    
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                    }
                }
                .foregroundColor(isLocked ? Color("SecondaryText") : (isSelected ? Color(red: 0.95, green: 0.77, blue: 0.06) : Color("PrimaryText")))
                
                // Progress indicator for locked tabs
                if isLocked && mode.requiredFacts > 0 {
                    Text("\(totalDiscovered)/\(mode.requiredFacts)")
                        .font(.system(size: 9))
                        .foregroundColor(Color("SecondaryText"))
                }
                
                // Selection indicator
                Rectangle()
                    .fill(isSelected ? Color(red: 0.95, green: 0.77, blue: 0.06) : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .disabled(isLocked)
    }
}

// MARK: - Discover Content (Categories)
struct DiscoverContent: View {
    let factsManager: ContraryFactsManager
    let progressManager: UserProgressManager
    @Binding var selectedCategory: String?
    @Binding var showCategoryDetail: Bool
    let categoriesWithProgress: Int
    let totalCategories: Int
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress overview
            ProgressOverviewCard(
                categoriesWithProgress: categoriesWithProgress,
                totalCategories: totalCategories,
                totalDiscovered: progressManager.userProgress.totalDiscovered
            )
            .padding(.horizontal)
            
            // Categories grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(factsManager.categories, id: \.key) { category in
                    if let enhanced = EnhancedCategory.getCategoryMetadata(for: category.key) {
                        CategoryCard(
                            enhanced: enhanced,
                            progress: progressManager.getCategoryProgress(for: category.key),
                            totalFacts: factsManager.getFactsForCategory(category.key).count
                        ) {
                            selectedCategory = category.key
                            showCategoryDetail = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding(.top, 20)
    }
}

// MARK: - Journey Content (Belief Evolution)
struct JourneyContent: View {
    let beliefTracker: BeliefEvolutionTracker
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    @State private var showBeliefInput = false
    @State private var selectedFact: ContraryFact?
    
    var body: some View {
        VStack(spacing: 20) {
            if beliefTracker.trackedBeliefs.isEmpty {
                // Onboarding state
                BeliefTrackingOnboarding(
                    recentFactsDiscovered: progressManager.userProgress.totalDiscovered,
                    onStartTracking: {
                        showBeliefInput = true
                    }
                )
            } else {
                // Active tracking state
                ActiveBeliefTracking(
                    beliefTracker: beliefTracker,
                    onAddBelief: {
                        showBeliefInput = true
                    }
                )
            }
            
            // Recent discoveries that might change beliefs
            if progressManager.userProgress.totalDiscovered > 0 {
                RecentDiscoveriesSection(
                    progressManager: progressManager,
                    factsManager: factsManager,
                    onFactTap: { fact in
                        selectedFact = fact
                        showBeliefInput = true
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .sheet(isPresented: $showBeliefInput) {
            BeliefInputView(
                beliefTracker: beliefTracker,
                contextFact: selectedFact
            )
        }
    }
}

// MARK: - Insights Content (Wisdom Synthesis)
struct InsightsContent: View {
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    
    var personalizedInsights: [PatternInsight] {
        generatePersonalizedInsights()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Milestone achievements
            MilestonesSection(progressManager: progressManager)
            
            // Cross-domain patterns
            if !personalizedInsights.isEmpty {
                PatternInsightsSection(insights: personalizedInsights)
            }
            
            // Intellectual streak
            StreakCard(progressManager: progressManager)
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
    }
    
    func generatePersonalizedInsights() -> [PatternInsight] {
        let exploredCategories = progressManager.getExploredCategories()
        
        guard exploredCategories.count >= 2 else { return [] }
        
        var insights: [PatternInsight] = []
        
        // Generate insights based on explored categories
        if exploredCategories.contains("technology") && exploredCategories.contains("society") {
            insights.append(PatternInsight(
                icon: "🔄",
                title: "Tech-Society Bridge",
                description: "You're exploring how technology shapes social norms",
                factCount: progressManager.userProgress.totalDiscovered
            ))
        }
        
        if exploredCategories.contains("business") && exploredCategories.contains("psychology") {
            insights.append(PatternInsight(
                icon: "🧠",
                title: "Behavioral Economics",
                description: "You're discovering psychological drivers in business",
                factCount: progressManager.userProgress.totalDiscovered
            ))
        }
        
        return insights
    }
}

// MARK: - Supporting Components

struct ProgressOverviewCard: View {
    let categoriesWithProgress: Int
    let totalCategories: Int
    let totalDiscovered: Int
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("YOUR PROGRESS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color("SecondaryText"))
                    .tracking(0.5)
                
                Text("\(totalDiscovered) facts discovered")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("PrimaryText"))
                
                Text("\(categoriesWithProgress) of \(totalCategories) territories explored")
                    .font(.system(size: 12))
                    .foregroundColor(Color("SubtitleText"))
            }
            
            Spacer()
            
            // Visual progress indicator
            ZStack {
                Circle()
                    .stroke(Color("CardBackground"), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(categoriesWithProgress) / CGFloat(max(totalCategories, 1)))
                    .stroke(Color(red: 0.95, green: 0.77, blue: 0.06), lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int((CGFloat(categoriesWithProgress) / CGFloat(max(totalCategories, 1))) * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("PrimaryText"))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("CardBackground").opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct CategoryCard: View {
    let enhanced: EnhancedCategory
    let progress: UserProgress.CategoryProgress?
    let totalFacts: Int
    let action: () -> Void
    
    var contraryHook: String {
        switch enhanced.base.key {
        case "business":
            return "What if everything you know about business success is wrong?"
        case "technology":
            return "The tech industry's biggest lies, exposed"
        case "society":
            return "Society's comfortable myths, uncomfortable truths"
        case "psychology":
            return "Your mind's hidden biases revealed"
        case "history":
            return "History's inconvenient truths"
        case "science":
            return "When scientific consensus gets it wrong"
        default:
            return "Challenge what you think you know"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon and progress
                HStack {
                    Text(enhanced.icon)
                        .font(.system(size: 28))
                    
                    Spacer()
                    
                    if let progress = progress, progress.discovered > 0 {
                        Text("\(progress.discovered)/\(totalFacts)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2))
                            )
                    }
                }
                
                // Title
                Text(enhanced.base.displayName.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("PrimaryText"))
                    .tracking(0.5)
                
                // Hook
                Text(contraryHook)
                    .font(.system(size: 11))
                    .foregroundColor(Color("SubtitleText"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Progress bar
                if let progress = progress, progress.discovered > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color("CardBackground").opacity(0.3))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(enhanced.color)
                                .frame(width: geometry.size.width * (CGFloat(progress.discovered) / CGFloat(max(totalFacts, 1))), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(enhanced.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(enhanced.color.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: enhanced.color.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BeliefTrackingOnboarding: View {
    let recentFactsDiscovered: Int
    let onStartTracking: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
            
            Text("Start Tracking Your Beliefs")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color("PrimaryText"))
            
            Text("You've discovered \(recentFactsDiscovered) contrarian facts. Has anything changed how you think? Track your intellectual evolution.")
                .font(.system(size: 14))
                .foregroundColor(Color("SubtitleText"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onStartTracking) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Track My First Belief Change")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(red: 0.95, green: 0.77, blue: 0.06))
                )
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
        )
    }
}

// MARK: - Supporting Models

struct PatternInsight {
    let icon: String
    let title: String
    let description: String
    let factCount: Int
}

struct Milestone {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requiredFacts: Int
    let isUnlocked: Bool
}

// Continue with remaining supporting views...
// (CategoryDetailView, KnowledgeGraphView, BeliefEvolutionTracker, etc. remain the same)