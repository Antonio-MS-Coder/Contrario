import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var factsManager: ContraryFactsManager
    @StateObject private var progressManager = UserProgressManager()
    @StateObject private var beliefTracker = BeliefEvolutionTracker()
    @State private var selectedCategory: String?
    @State private var showCategoryDetail = false
    @State private var showKnowledgeGraph = false
    @State private var viewMode: ExploreViewMode = .categories
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                        Color(red: 0.16, green: 0.11, blue: 0.29),
                        Color(red: 0.31, green: 0.20, blue: 0.48)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced header with view mode toggle
                    ExploreHeader(
                        viewMode: $viewMode,
                        onKnowledgeGraphTap: {
                            showKnowledgeGraph = true
                        }
                    )
                    
                    // Content based on view mode
                    switch viewMode {
                    case .categories:
                        CategoriesContent(
                            factsManager: factsManager,
                            progressManager: progressManager,
                            selectedCategory: $selectedCategory,
                            showCategoryDetail: $showCategoryDetail,
                            categoriesWithProgress: categoriesWithProgress,
                            totalCategories: totalCategories
                        )
                    
                    case .beliefsTracker:
                        BeliefTrackerContent(
                            beliefTracker: beliefTracker,
                            progressManager: progressManager
                        )
                    
                    case .synthesis:
                        WisdomSynthesisContent(
                            progressManager: progressManager,
                            factsManager: factsManager
                        )
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

// MARK: - Header Section
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("EXPLORE TERRITORIES")
                .font(.system(size: 32, weight: .heavy, design: .default))
                .foregroundColor(.white)
                .tracking(1.5)
                .padding(.top, 20)
            
            Text("Each category is a rabbit hole of revelations")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let categoriesDiscovered: Int
    let totalCategories: Int
    let progressManager: UserProgressManager
    let totalFacts: Int
    
    var progressPercentage: Double {
        guard totalCategories > 0 else { return 0 }
        return Double(categoriesDiscovered) / Double(totalCategories)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("YOUR INTELLECTUAL")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    Text("JOURNEY")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                }
                
                Spacer()
                
                Text("\(categoriesDiscovered) / \(totalCategories) DISCOVERED")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Progress Bar
            ProgressBar(progressPercentage: progressPercentage)
            
            // Stats
            HStack(spacing: 20) {
                StatItem(
                    icon: "lightbulb.fill",
                    value: "\(progressManager.userProgress.totalDiscovered)",
                    label: "Facts Discovered"
                )
                
                StatItem(
                    icon: "star.fill",
                    value: "\(Int(progressPercentage * 100))%",
                    label: "Complete"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progressPercentage: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 8)
                
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.77, blue: 0.06),
                        Color(red: 0.95, green: 0.42, blue: 0.26),
                        Color(red: 0.91, green: 0.12, blue: 0.39)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * progressPercentage, height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressPercentage)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Categories Grid
struct CategoriesGrid: View {
    let categories: [ContraryCategory]
    let factsManager: ContraryFactsManager
    let progressManager: UserProgressManager
    @Binding var selectedCategory: String?
    @Binding var showCategoryDetail: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(categories, id: \.key) { category in
                if let enhanced = EnhancedCategory.getCategoryMetadata(for: category.key) {
                    TerritoryCard(
                        enhanced: enhanced,
                        factCount: factsManager.getFactsForCategory(category.key).count,
                        progressManager: progressManager,
                        isSelected: selectedCategory == category.key
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedCategory = category.key
                            showCategoryDetail = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Territory Card
struct TerritoryCard: View {
    let enhanced: EnhancedCategory
    let factCount: Int
    let progressManager: UserProgressManager
    let isSelected: Bool
    let action: () -> Void
    
    var progress: (discovered: Int, total: Int) {
        progressManager.getCategoryProgress(enhanced.base.key, totalFacts: factCount)
    }
    
    var categoryState: CategoryState {
        progressManager.getCategoryState(enhanced.base.key, totalFacts: factCount)
    }
    
    var isCompleted: Bool {
        if case .completed = categoryState {
            return true
        }
        return false
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    // Background with category color
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            isCompleted ? 
                            enhanced.color.opacity(0.9) : 
                            (progress.discovered > 0 ? enhanced.color.opacity(0.7) : Color.white.opacity(0.15))
                        )
                    
                    VStack(spacing: 12) {
                        // Icon
                        Image(systemName: enhanced.base.icon)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Category Name
                        Text(enhanced.base.displayName.uppercased())
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 10)
                        
                        // Tagline
                        Text(enhanced.tagline)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 10)
                        
                        Spacer()
                        
                        // Progress Indicator
                        ProgressIndicator(progress: progress, isCompleted: isCompleted)
                            .padding(.bottom, 15)
                    }
                    
                    // Progress Bar (bottom)
                    if progress.discovered > 0 && !isCompleted {
                        VStack {
                            Spacer()
                            CategoryProgressBar(progress: progress)
                        }
                    }
                }
                .frame(height: 180)
            }
            .shadow(color: enhanced.color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let progress: (discovered: Int, total: Int)
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                Text("COMPLETE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(progress.discovered)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(progress.discovered > 0 ? .white : Color(red: 0.95, green: 0.77, blue: 0.06))
                Text("/ \(progress.total)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(progress.discovered > 0 ? .white.opacity(0.8) : .white.opacity(0.6))
            }
        }
    }
}

// MARK: - Category Progress Bar
struct CategoryProgressBar: View {
    let progress: (discovered: Int, total: Int)
    
    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.77, blue: 0.06),
                    Color(red: 0.95, green: 0.42, blue: 0.26)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(
                width: geometry.size.width * (Double(progress.discovered) / Double(progress.total)),
                height: 4
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 0)
                    .path(in: CGRect(x: 0, y: 0, width: geometry.size.width, height: 4))
            )
        }
        .frame(height: 4)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0
            )
        )
    }
}

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let enhanced: EnhancedCategory
    let facts: [ContraryFact]
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    @Environment(\.dismiss) var dismiss
    
    var progress: (discovered: Int, total: Int) {
        progressManager.getCategoryProgress(enhanced.base.key, totalFacts: facts.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        enhanced.color.opacity(0.3),
                        Color(red: 0.16, green: 0.11, blue: 0.29)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    CategoryDetailHeader(enhanced: enhanced, progress: progress)
                        .padding()
                    
                    // Facts List
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Array(facts.enumerated()), id: \.element.id) { index, fact in
                                FactCard(
                                    fact: fact,
                                    isDiscovered: progressManager.isFactDiscovered(fact.id),
                                    categoryColor: enhanced.color
                                ) {
                                    progressManager.markFactAsDiscovered(fact)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(enhanced.color)
                }
            }
        }
    }
}

// MARK: - Category Detail Header
struct CategoryDetailHeader: View {
    let enhanced: EnhancedCategory
    let progress: (discovered: Int, total: Int)
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: enhanced.base.icon)
                .font(.system(size: 48))
                .foregroundColor(enhanced.color)
            
            Text(enhanced.base.displayName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text(enhanced.description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Stats
            HStack(spacing: 20) {
                Label("\(enhanced.estimatedMinutes) min", systemImage: "clock")
                Label(enhanced.difficulty.rawValue, systemImage: enhanced.difficulty.icon)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.7))
            
            // Progress
            HStack {
                Text("Progress: \(progress.discovered)/\(progress.total)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                ProgressView(value: Double(progress.discovered), total: Double(progress.total))
                    .progressViewStyle(.linear)
                    .tint(enhanced.color)
                    .scaleEffect(x: 1, y: 2)
                    .frame(width: 100)
            }
        }
    }
}

// MARK: - Fact Card
struct FactCard: View {
    let fact: ContraryFact
    let isDiscovered: Bool
    let categoryColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: isDiscovered ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isDiscovered ? .green : .gray)
                    
                    Text(fact.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isDiscovered ? .white : .white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                
                if isDiscovered && !fact.contraryInsight.isEmpty {
                    Text(fact.contraryInsight)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDiscovered ? categoryColor.opacity(0.2) : Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}