import SwiftUI
import SafariServices

struct NewsView: View {
    @StateObject private var hnService = HackerNewsService()
    @State private var selectedType: HackerNewsService.StoryType = .top
    @State private var selectedStory: HNStory?
    @State private var showingSafari = false
    
    var body: some View {
        ZStack {
            // Clean gradient background matching HomeView
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.11, blue: 0.14),
                    Color(red: 0.18, green: 0.16, blue: 0.24)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Minimal header similar to HomeView
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hacker News")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Latest tech news and discussions")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        // Subtle story count indicator
                        if !currentStories.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                                Text("\(currentStories.count)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Story type selector - minimal pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
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
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)
                
                // Stories content
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
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        Text(error)
                            .foregroundColor(.white.opacity(0.6))
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
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(currentStories) { story in
                                MinimalStoryCard(
                                    story: story,
                                    onTap: {
                                        selectedStory = story
                                        showingSafari = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await hnService.refresh(type: selectedType)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSafari) {
            if let story = selectedStory {
                SafariView(url: storyURL(for: story))
                    .ignoresSafeArea()
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
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? Color(red: 0.16, green: 0.11, blue: 0.29) : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(red: 0.95, green: 0.77, blue: 0.06) : Color.white.opacity(0.08))
                )
        }
    }
}

// MARK: - Minimal Story Card
struct MinimalStoryCard: View {
    let story: HNStory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(story.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                
                // Metadata row
                HStack(spacing: 16) {
                    // Points
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 10))
                        Text("\(story.score)")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    
                    // Comments
                    if story.commentCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 10))
                            Text("\(story.commentCount)")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white.opacity(0.5))
                    }
                    
                    // Author
                    Text("by \(story.by)")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    // Time
                    Text(story.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
                
                // Domain (if available)
                if let domain = story.domain {
                    Text(domain)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                        )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.20, blue: 0.24),
                                Color(red: 0.16, green: 0.16, blue: 0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredControlTintColor = UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)
        safari.preferredBarTintColor = UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1.0)
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}