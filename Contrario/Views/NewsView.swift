import SwiftUI

struct NewsView: View {
    @StateObject private var hnService = HackerNewsService()
    @State private var selectedType: HackerNewsService.StoryType = .top
    @State private var selectedStory: HNStory?
    @State private var showingSafari = false
    
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
                    // Header
                    VStack(spacing: 12) {
                        // Title
                        HStack {
                            Text("Hacker News")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("PrimaryText"))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Subtitle
                        HStack {
                            Text("Latest tech news and discussions")
                                .font(.system(size: 14))
                                .foregroundColor(Color("SubtitleText"))
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
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryText")))
                            .scaleEffect(1.2)
                        Spacer()
                    } else if let error = hnService.errorMessage {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(Color("SubtitleText"))
                            Text(error)
                                .foregroundColor(Color("SubtitleText"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Retry") {
                                Task {
                                    await hnService.loadStories(type: selectedType)
                                }
                            }
                            .foregroundColor(Color("PrimaryText"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color("CardBackground"))
                            .cornerRadius(20)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(currentStories) { story in
                                    StoryCard(
                                        story: story,
                                        onStoryTap: {
                                            selectedStory = story
                                            showingSafari = true
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
                .foregroundColor(isSelected ? Color(red: 0.16, green: 0.11, blue: 0.29) : Color("PrimaryText"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color("AccentBrown") : Color("CardBackground")
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Story Card

struct StoryCard: View {
    let story: HNStory
    let onStoryTap: () -> Void
    
    var body: some View {
        Button(action: onStoryTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(story.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            
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
                        .foregroundColor(Color("SubtitleText"))
                    }
                    
                    // Author
                    Text("by \(story.by)")
                        .font(.system(size: 12))
                        .foregroundColor(Color("SubtitleText"))
                    
                    Spacer()
                    
                    // Time
                    Text(story.formattedTime)
                        .font(.system(size: 12))
                        .foregroundColor(Color("SubtitleText").opacity(0.8))
                }
            
                // Domain (if available)
                if let domain = story.domain {
                    Text(domain)
                        .font(.system(size: 11))
                        .foregroundColor(Color("SubtitleText").opacity(0.7))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("CardBackground"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("CardBackground").opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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