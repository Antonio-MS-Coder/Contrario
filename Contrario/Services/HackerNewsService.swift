import Foundation
import SwiftUI

// MARK: - Hacker News Models

struct HNStory: Identifiable, Codable {
    let id: Int
    let title: String
    let url: String?
    let score: Int
    let by: String
    let time: Int
    let descendants: Int?
    let text: String?
    let type: String
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var domain: String? {
        guard let url = url,
              let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else { return nil }
        return host.replacingOccurrences(of: "www.", with: "")
    }
    
    var commentCount: Int {
        descendants ?? 0
    }
}

struct HNComment: Identifiable, Codable {
    let id: Int
    let by: String?
    let text: String?
    let time: Int
    let parent: Int
    let kids: [Int]?
    let type: String
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Hacker News Service

class HackerNewsService: ObservableObject {
    @Published var topStories: [HNStory] = []
    @Published var bestStories: [HNStory] = []
    @Published var newStories: [HNStory] = []
    @Published var askStories: [HNStory] = []
    @Published var showStories: [HNStory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    private let session = URLSession.shared
    private var loadedStoryIds = Set<Int>()
    
    enum StoryType: String, CaseIterable {
        case top = "topstories"
        case best = "beststories"
        case new = "newstories"
        case ask = "askstories"
        case show = "showstories"
        
        var displayName: String {
            switch self {
            case .top: return "Top"
            case .best: return "Best"
            case .new: return "New"
            case .ask: return "Ask HN"
            case .show: return "Show HN"
            }
        }
    }
    
    func loadStories(type: StoryType, limit: Int = 30) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Get story IDs
            let idsURL = URL(string: "\(baseURL)/\(type.rawValue).json")!
            let (data, _) = try await session.data(from: idsURL)
            let storyIds = try JSONDecoder().decode([Int].self, from: data)
            
            // Load first batch of stories
            let limitedIds = Array(storyIds.prefix(limit))
            var stories: [HNStory] = []
            
            // Load stories concurrently but in batches to avoid overwhelming the API
            let batchSize = 10
            for i in stride(from: 0, to: limitedIds.count, by: batchSize) {
                let batch = Array(limitedIds[i..<min(i + batchSize, limitedIds.count)])
                let batchStories = await loadStoriesBatch(ids: batch)
                stories.append(contentsOf: batchStories)
            }
            
            // Sort by score or time depending on type
            if type == .new {
                stories.sort { $0.time > $1.time }
            } else {
                stories.sort { $0.score > $1.score }
            }
            
            await MainActor.run {
                switch type {
                case .top:
                    self.topStories = stories
                case .best:
                    self.bestStories = stories
                case .new:
                    self.newStories = stories
                case .ask:
                    self.askStories = stories
                case .show:
                    self.showStories = stories
                }
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load stories: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func loadStoriesBatch(ids: [Int]) async -> [HNStory] {
        await withTaskGroup(of: HNStory?.self) { group in
            for id in ids {
                group.addTask {
                    await self.loadStory(id: id)
                }
            }
            
            var stories: [HNStory] = []
            for await story in group {
                if let story = story {
                    stories.append(story)
                }
            }
            return stories
        }
    }
    
    private func loadStory(id: Int) async -> HNStory? {
        // Avoid duplicate loading
        if loadedStoryIds.contains(id) {
            return nil
        }
        
        do {
            let url = URL(string: "\(baseURL)/item/\(id).json")!
            let (data, _) = try await session.data(from: url)
            let story = try JSONDecoder().decode(HNStory.self, from: data)
            loadedStoryIds.insert(id)
            return story
        } catch {
            print("Failed to load story \(id): \(error)")
            return nil
        }
    }
    
    func loadComments(for storyId: Int) async -> [HNComment] {
        do {
            let url = URL(string: "\(baseURL)/item/\(storyId).json")!
            let (data, _) = try await session.data(from: url)
            
            if let story = try? JSONDecoder().decode(HNStory.self, from: data),
               let kids = story.kids {
                return await loadCommentsBatch(ids: Array(kids.prefix(20)))
            }
        } catch {
            print("Failed to load comments: \(error)")
        }
        return []
    }
    
    private func loadCommentsBatch(ids: [Int]) async -> [HNComment] {
        await withTaskGroup(of: HNComment?.self) { group in
            for id in ids {
                group.addTask {
                    await self.loadComment(id: id)
                }
            }
            
            var comments: [HNComment] = []
            for await comment in group {
                if let comment = comment {
                    comments.append(comment)
                }
            }
            return comments.sorted { $0.time > $1.time }
        }
    }
    
    private func loadComment(id: Int) async -> HNComment? {
        do {
            let url = URL(string: "\(baseURL)/item/\(id).json")!
            let (data, _) = try await session.data(from: url)
            return try JSONDecoder().decode(HNComment.self, from: data)
        } catch {
            print("Failed to load comment \(id): \(error)")
            return nil
        }
    }
    
    func refresh(type: StoryType) async {
        loadedStoryIds.removeAll()
        await loadStories(type: type)
    }
}

// Extension to decode optional kids array
extension HNStory {
    var kids: [Int]? {
        // This would be populated if the API includes it
        return nil
    }
}