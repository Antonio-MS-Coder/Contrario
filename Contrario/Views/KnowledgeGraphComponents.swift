import SwiftUI

// MARK: - Belief Evolution Tracker
class BeliefEvolutionTracker: ObservableObject {
    @Published var trackedBeliefs: [TrackedBelief] = []
    @Published var beliefChanges: [BeliefChange] = []
    
    init() {
        loadBeliefs()
    }
    
    func addBelief(_ belief: TrackedBelief) {
        trackedBeliefs.append(belief)
        saveBeliefs()
    }
    
    func updateBelief(_ belief: TrackedBelief, newPosition: String) {
        if let index = trackedBeliefs.firstIndex(where: { $0.id == belief.id }) {
            let change = BeliefChange(
                id: UUID().uuidString,
                beliefId: belief.id,
                fromPosition: belief.currentPosition,
                toPosition: newPosition,
                date: Date(),
                triggerFact: nil
            )
            beliefChanges.append(change)
            trackedBeliefs[index].currentPosition = newPosition
            trackedBeliefs[index].lastUpdated = Date()
            saveBeliefs()
        }
    }
    
    private func loadBeliefs() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "trackedBeliefs"),
           let decoded = try? JSONDecoder().decode([TrackedBelief].self, from: data) {
            trackedBeliefs = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: "beliefChanges"),
           let decoded = try? JSONDecoder().decode([BeliefChange].self, from: data) {
            beliefChanges = decoded
        }
    }
    
    private func saveBeliefs() {
        if let encoded = try? JSONEncoder().encode(trackedBeliefs) {
            UserDefaults.standard.set(encoded, forKey: "trackedBeliefs")
        }
        
        if let encoded = try? JSONEncoder().encode(beliefChanges) {
            UserDefaults.standard.set(encoded, forKey: "beliefChanges")
        }
    }
}

struct TrackedBelief: Codable, Identifiable {
    let id: String
    let topic: String
    var currentPosition: String
    let initialPosition: String
    let dateAdded: Date
    var lastUpdated: Date
}

struct BeliefChange: Codable {
    let id: String
    let beliefId: String
    let fromPosition: String
    let toPosition: String
    let date: Date
    let triggerFact: String?
}

// MARK: - Active Belief Tracking View
struct ActiveBeliefTracking: View {
    let beliefTracker: BeliefEvolutionTracker
    let onAddBelief: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("YOUR BELIEF EVOLUTION")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("SecondaryText"))
                    .tracking(0.5)
                
                Spacer()
                
                Button(action: onAddBelief) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                }
            }
            
            ForEach(beliefTracker.trackedBeliefs) { belief in
                BeliefCard(belief: belief, changes: beliefTracker.beliefChanges.filter { $0.beliefId == belief.id })
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
        )
    }
}

struct BeliefCard: View {
    let belief: TrackedBelief
    let changes: [BeliefChange]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(belief.topic)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("PrimaryText"))
            
            HStack {
                Text("Current: \(belief.currentPosition)")
                    .font(.system(size: 12))
                    .foregroundColor(Color("SubtitleText"))
                
                Spacer()
                
                if changes.count > 0 {
                    Text("\(changes.count) changes")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground").opacity(0.5))
        )
    }
}

// MARK: - Recent Discoveries Section
struct RecentDiscoveriesSection: View {
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    let onFactTap: (ContraryFact) -> Void
    
    var recentFacts: [ContraryFact] {
        // Get last 5 discovered facts
        let discoveredIds = Array(progressManager.userProgress.discoveredFacts.prefix(5))
        return factsManager.facts.filter { discoveredIds.contains($0.id) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT DISCOVERIES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("SecondaryText"))
                .tracking(0.5)
            
            Text("Tap a fact if it changed your thinking")
                .font(.system(size: 11))
                .foregroundColor(Color("SubtitleText"))
            
            ForEach(recentFacts, id: \.id) { fact in
                Button(action: { onFactTap(fact) }) {
                    HStack {
                        Text(fact.text)
                            .font(.system(size: 13))
                            .foregroundColor(Color("PrimaryText"))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundColor(Color("SecondaryText"))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBackground").opacity(0.5))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
        )
    }
}

// MARK: - Belief Input View
struct BeliefInputView: View {
    let beliefTracker: BeliefEvolutionTracker
    let contextFact: ContraryFact?
    @Environment(\.dismiss) var dismiss
    
    @State private var topic = ""
    @State private var initialPosition = ""
    @State private var currentPosition = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let fact = contextFact {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Inspired by:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color("SecondaryText"))
                            
                            Text(fact.text)
                                .font(.system(size: 14))
                                .foregroundColor(Color("SubtitleText"))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("CardBackground").opacity(0.5))
                                )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What belief are you tracking?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("PrimaryText"))
                        
                        TextField("e.g., The role of technology in society", text: $topic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What did you originally believe?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("PrimaryText"))
                        
                        TextField("Your initial position...", text: $initialPosition, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What do you believe now?")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("PrimaryText"))
                        
                        TextField("Your current position...", text: $currentPosition, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                .padding()
            }
            .background(Color("BackgroundGradientStart"))
            .navigationTitle("Track Belief Evolution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let belief = TrackedBelief(
                            id: UUID().uuidString,
                            topic: topic,
                            currentPosition: currentPosition.isEmpty ? initialPosition : currentPosition,
                            initialPosition: initialPosition,
                            dateAdded: Date(),
                            lastUpdated: Date()
                        )
                        beliefTracker.addBelief(belief)
                        dismiss()
                    }
                    .disabled(topic.isEmpty || initialPosition.isEmpty)
                }
            }
        }
    }
}

// MARK: - Milestones Section
struct MilestonesSection: View {
    let progressManager: UserProgressManager
    
    var milestones: [Milestone] {
        [
            Milestone(
                id: "first",
                title: "First Contrarian",
                description: "Discovered your first fact",
                icon: "🎯",
                requiredFacts: 1,
                isUnlocked: progressManager.userProgress.totalDiscovered >= 1
            ),
            Milestone(
                id: "explorer",
                title: "Territory Explorer",
                description: "Explored 3 different categories",
                icon: "🗺️",
                requiredFacts: 5,
                isUnlocked: progressManager.getExploredCategories().count >= 3
            ),
            Milestone(
                id: "challenger",
                title: "Belief Challenger",
                description: "Discovered 10 contrarian facts",
                icon: "💡",
                requiredFacts: 10,
                isUnlocked: progressManager.userProgress.totalDiscovered >= 10
            ),
            Milestone(
                id: "synthesizer",
                title: "Wisdom Synthesizer",
                description: "Found patterns across domains",
                icon: "🧩",
                requiredFacts: 15,
                isUnlocked: progressManager.userProgress.totalDiscovered >= 15
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MILESTONES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("SecondaryText"))
                .tracking(0.5)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(milestones, id: \.id) { milestone in
                    MilestoneCard(milestone: milestone)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
        )
    }
}

struct MilestoneCard: View {
    let milestone: Milestone
    
    var body: some View {
        VStack(spacing: 8) {
            Text(milestone.icon)
                .font(.system(size: 24))
                .opacity(milestone.isUnlocked ? 1 : 0.3)
            
            Text(milestone.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(milestone.isUnlocked ? Color("PrimaryText") : Color("SecondaryText"))
                .multilineTextAlignment(.center)
            
            if milestone.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(milestone.isUnlocked ? 
                      Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.1) : 
                      Color("CardBackground").opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(milestone.isUnlocked ? 
                                Color(red: 0.95, green: 0.77, blue: 0.06) : 
                                Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Pattern Insights Section
struct PatternInsightsSection: View {
    let insights: [PatternInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CROSS-DOMAIN PATTERNS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("SecondaryText"))
                .tracking(0.5)
            
            ForEach(insights, id: \.title) { insight in
                HStack(spacing: 12) {
                    Text(insight.icon)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color("PrimaryText"))
                        
                        Text(insight.description)
                            .font(.system(size: 11))
                            .foregroundColor(Color("SubtitleText"))
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardBackground").opacity(0.5))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackground"))
        )
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let progressManager: UserProgressManager
    
    var streakMessage: String {
        let lastDiscovery = progressManager.userProgress.lastDiscoveryDate ?? Date()
        let daysSince = Calendar.current.dateComponents([.day], from: lastDiscovery, to: Date()).day ?? 0
        
        if daysSince == 0 {
            return "You're on fire! Keep discovering"
        } else if daysSince == 1 {
            return "Continue your intellectual journey"
        } else {
            return "Ready to restart your journey?"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    
                    Text("INTELLECTUAL MOMENTUM")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("SecondaryText"))
                        .tracking(0.5)
                }
                
                Text(streakMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color("PrimaryText"))
                
                Text("\(progressManager.userProgress.totalDiscovered) total discoveries")
                    .font(.system(size: 11))
                    .foregroundColor(Color("SubtitleText"))
            }
            
            Spacer()
        }
        .padding()
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

// MARK: - Category Detail View
struct CategoryDetailView: View {
    let enhanced: EnhancedCategory
    let facts: [ContraryFact]
    let progressManager: UserProgressManager
    let factsManager: ContraryFactsManager
    @Environment(\.dismiss) var dismiss
    
    var discoveredCount: Int {
        facts.filter { progressManager.userProgress.discoveredFacts.contains($0.id) }.count
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(enhanced.icon)
                                .font(.system(size: 40))
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(discoveredCount) / \(facts.count)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color("PrimaryText"))
                                
                                Text("discovered")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color("SubtitleText"))
                            }
                        }
                        
                        Text(enhanced.base.displayName.uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("PrimaryText"))
                            .tracking(1)
                        
                        Text(enhanced.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color("SubtitleText"))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(enhanced.color.opacity(0.1))
                    )
                    
                    // Facts list
                    VStack(spacing: 12) {
                        ForEach(facts, id: \.id) { fact in
                            FactRow(
                                fact: fact,
                                isDiscovered: progressManager.userProgress.discoveredFacts.contains(fact.id),
                                onTap: {
                                    progressManager.markFactAsDiscovered(fact)
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color("BackgroundGradientStart"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FactRow: View {
    let fact: ContraryFact
    let isDiscovered: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(fact.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("PrimaryText"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if isDiscovered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    }
                }
                
                if !fact.contraryInsight.isEmpty {
                    Text(fact.contraryInsight)
                        .font(.system(size: 12))
                        .foregroundColor(Color("SubtitleText"))
                        .italic()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDiscovered ? 
                          Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.05) : 
                          Color("CardBackground"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isDiscovered ? 
                                    Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.3) : 
                                    Color("CardBackground").opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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
                Color("BackgroundGradientStart")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Knowledge Network")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("PrimaryText"))
                    
                    Text("Your intellectual connections across domains")
                        .font(.system(size: 14))
                        .foregroundColor(Color("SubtitleText"))
                    
                    // Placeholder for actual graph visualization
                    ZStack {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2))
                                .frame(width: 60, height: 60)
                                .offset(
                                    x: CGFloat.random(in: -100...100),
                                    y: CGFloat.random(in: -150...150)
                                )
                        }
                        
                        Text("🧠")
                            .font(.system(size: 40))
                    }
                    .frame(height: 400)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("CardBackground").opacity(0.3))
                    )
                    
                    Text("Visualization coming soon")
                        .font(.system(size: 12))
                        .foregroundColor(Color("SecondaryText"))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Enhanced Category is defined in UserProgress.swift