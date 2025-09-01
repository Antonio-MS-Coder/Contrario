import SwiftUI

struct NewsView: View {
    @StateObject private var hnService = HackerNewsService()
    @StateObject private var contraryLensService = ContraryLensService()
    @State private var selectedType: HackerNewsService.StoryType = .top
    @State private var selectedStory: HNStory?
    @State private var showingSafari = false
    @State private var showContraryAnalysis = false
    @State private var contraryLensEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color("BackgroundGradientStart"), Color("BackgroundGradientEnd")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced header with contrarian lens toggle
                    VStack(spacing: 12) {
                        // Title and lens toggle
                        HStack {
                            Text("News Lens")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Contrarian lens toggle
                            Button(action: {
                                contraryLensEnabled.toggle()
                                HapticManager.shared.impact(style: .light)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: contraryLensEnabled ? "eye.fill" : "eye.slash.fill")
                                        .font(.system(size: 14))
                                    Text("Contrarian Lens")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(contraryLensEnabled ? Color(red: 0.95, green: 0.77, blue: 0.06) : .white.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(contraryLensEnabled ? Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2) : Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(contraryLensEnabled ? Color(red: 0.95, green: 0.77, blue: 0.06) : Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Subtitle
                        HStack {
                            Text(contraryLensEnabled ? "Challenging mainstream narratives" : "Standard news feed")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Story type picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(HackerNewsService.StoryType.allCases, id: \.self) { type in
                                    StoryTypeButton(
                                        type: type,
                                        isSelected: selectedType == type
                                    ) {
                                        selectedType = type
                                        Task {
                                            await hnService.loadStories(type: type)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.2))
                    
                    // Stories list
                    if hnService.isLoading && currentStories.isEmpty {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        Spacer()
                    } else if let error = hnService.errorMessage {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                            Text(error)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Retry") {
                                Task {
                                    await hnService.loadStories(type: selectedType)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(currentStories) { story in
                                    EnhancedStoryCard(
                                        story: story,
                                        contraryLensEnabled: contraryLensEnabled,
                                        contraryAnalysis: contraryLensService.getAnalysis(for: story.id),
                                        onStoryTap: {
                                            selectedStory = story
                                            showingSafari = true
                                        },
                                        onAnalysisTap: {
                                            selectedStory = story
                                            showContraryAnalysis = true
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await hnService.refresh(type: selectedType)
                        }
                    }
                }
            }
            .navigationTitle("Hacker News")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSafari) {
                if let story = selectedStory {
                    SafariView(url: storyURL(for: story))
                        .ignoresSafeArea()
                }
            }
            .sheet(isPresented: $showContraryAnalysis) {
                if let story = selectedStory {
                    ContraryAnalysisView(
                        story: story,
                        analysis: contraryLensService.getAnalysis(for: story.id) ?? ContraryAnalysis.placeholder(for: story)
                    )
                }
            }
        }
        .task {
            await hnService.loadStories(type: selectedType)
        }
    }
    
    private var currentStories: [HNStory] {
        switch selectedType {
        case .top: return hnService.topStories
        case .best: return hnService.bestStories
        case .new: return hnService.newStories
        case .ask: return hnService.askStories
        case .show: return hnService.showStories
        }
    }
    
    private func storyURL(for story: HNStory) -> URL {
        if let urlString = story.url, let url = URL(string: urlString) {
            return url
        } else {
            // For Ask HN or text posts, link to HN discussion
            return URL(string: "https://news.ycombinator.com/item?id=\(story.id)")!
        }
    }
}

// MARK: - Story Type Button

struct StoryTypeButton: View {
    let type: HackerNewsService.StoryType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(type.displayName)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? Color(red: 0.16, green: 0.11, blue: 0.29) : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.white : Color.white.opacity(0.15)
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Enhanced Story Card

struct EnhancedStoryCard: View {
    let story: HNStory
    let contraryLensEnabled: Bool
    let contraryAnalysis: ContraryAnalysis?
    let onStoryTap: () -> Void
    let onAnalysisTap: () -> Void
    @State private var showFullAnalysis = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main story card
            Button(action: onStoryTap) {
                VStack(alignment: .leading, spacing: 8) {
                    // Title with contrarian indicator
                    HStack(alignment: .top, spacing: 8) {
                        Text(story.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if contraryLensEnabled && contraryAnalysis != nil {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                        }
                    }
                
                    // Metadata
                    HStack(spacing: 12) {
                        // Points
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 12))
                            Text("\(story.score)")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                        
                        // Comments
                        if story.commentCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 12))
                                Text("\(story.commentCount)")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Author
                        Text("by \(story.by)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        // Time
                        Text(story.formattedTime)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                
                    // Domain (if available)
                    if let domain = story.domain {
                        Text(domain)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Contrarian analysis preview (if enabled and available)
            if contraryLensEnabled, let analysis = contraryAnalysis {
                ContraryAnalysisPreview(
                    analysis: analysis,
                    onTap: onAnalysisTap
                )
                .transition(.slide)
            }
        }
    }
}

// MARK: - Safari View

import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Contrarian Analysis Components

struct ContraryAnalysisPreview: View {
    let analysis: ContraryAnalysis
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    
                    Text("CONTRARIAN PERSPECTIVE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                        .tracking(0.5)
                    
                    Spacer()
                    
                    Text("Tap to explore")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text(analysis.briefSummary)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContraryAnalysisView: View {
    let story: HNStory
    let analysis: ContraryAnalysis
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Story title
                    Text(story.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // Analysis sections
                    ForEach(analysis.sections, id: \.title) { section in
                        AnalysisSection(section: section)
                    }
                    
                    // Key questions
                    if !analysis.keyQuestions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("QUESTIONS TO CONSIDER")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                                .tracking(0.5)
                            
                            ForEach(analysis.keyQuestions, id: \.self) { question in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("?")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                                    
                                    Text(question)
                                        .font(.system(size: 15))
                                        .foregroundColor(.white.opacity(0.9))
                                }
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
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.16, green: 0.11, blue: 0.29),
                        Color(red: 0.26, green: 0.20, blue: 0.40)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
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

struct AnalysisSection: View {
    let section: ContraryAnalysis.AnalysisSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title.uppercased())
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                .tracking(0.5)
            
            Text(section.content)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Supporting Models and Services

struct ContraryAnalysis {
    let id: String
    let briefSummary: String
    let sections: [AnalysisSection]
    let keyQuestions: [String]
    
    struct AnalysisSection {
        let title: String
        let content: String
    }
    
    static func placeholder(for story: HNStory) -> ContraryAnalysis {
        ContraryAnalysis(
            id: "\(story.id)",
            briefSummary: "What if the conventional wisdom around this story is wrong?",
            sections: [
                AnalysisSection(
                    title: "Hidden Assumptions",
                    content: "This story presents certain assumptions as facts. What if these foundational beliefs are actually misconceptions that shape how we interpret the narrative?"
                ),
                AnalysisSection(
                    title: "Missing Context",
                    content: "Consider what information might be deliberately or accidentally omitted. What context could completely change our understanding of this situation?"
                ),
                AnalysisSection(
                    title: "Alternative Interpretation", 
                    content: "From a contrarian perspective, this could represent the opposite of what it appears to be. What if the real story is in what's not being said?"
                )
            ],
            keyQuestions: [
                "Who benefits from this narrative being widely accepted?",
                "What would change if the opposite were true?", 
                "What evidence would contradict this story?"
            ]
        )
    }
}

class ContraryLensService: ObservableObject {
    @Published var analyses: [String: ContraryAnalysis] = [:]
    private let cache = NSCache<NSString, NSString>()
    
    func getAnalysis(for storyId: Int) -> ContraryAnalysis? {
        let key = "\(storyId)"
        
        // Return cached analysis if available
        if let analysis = analyses[key] {
            return analysis
        }
        
        // Generate placeholder analysis (in real app, this would call AI service)
        let placeholder = ContraryAnalysis(
            id: key,
            briefSummary: "Challenging the mainstream narrative on this story",
            sections: [
                ContraryAnalysis.AnalysisSection(
                    title: "Devil's Advocate View",
                    content: "Consider that this story might be presenting only one side of a complex issue. What are the counterarguments?"
                ),
                ContraryAnalysis.AnalysisSection(
                    title: "Second-Order Effects",
                    content: "Beyond the immediate implications, what might be the unintended consequences that aren't being discussed?"
                )
            ],
            keyQuestions: [
                "What if this is correlation, not causation?",
                "Who has a vested interest in this perspective?"
            ]
        )
        
        analyses[key] = placeholder
        return placeholder
    }
    
    func generateAnalysis(for story: HNStory) async -> ContraryAnalysis {
        // Placeholder for AI-generated contrarian analysis
        // In production, this would call an AI service
        return ContraryAnalysis.placeholder(for: story)
    }
}