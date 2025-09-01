import Foundation
import SwiftUI

class UserJourneyManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalDaysEngaged: Int = 0
    @Published var lastVisitDate: Date?
    @Published var dailyDiscoveries: Int = 0
    @Published var weeklyGoal: Int = 21 // 3 discoveries per day
    @Published var weeklyProgress: Int = 0
    @Published var userLevel: UserLevel = .novice
    @Published var experiencePoints: Int = 0
    @Published var shouldShowDailyWisdom: Bool = false
    @Published var emotionalJourneyStage: EmotionalJourneyStage = .curiosity
    @Published var achievementHistory: [UnlockedAchievement] = []
    
    private let userDefaults = UserDefaults.standard
    private let streakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let lastVisitKey = "lastVisitDate"
    private let totalDaysKey = "totalDaysEngaged"
    private let dailyDiscoveriesKey = "dailyDiscoveries"
    private let weeklyProgressKey = "weeklyProgress"
    private let levelKey = "userLevel"
    private let experienceKey = "experiencePoints"
    private let weekStartKey = "weekStartDate"
    private let achievementsKey = "unlockedAchievements"
    private let emotionalStageKey = "emotionalJourneyStage"
    
    init() {
        loadUserJourney()
        checkStreakStatus()
    }
    
    // MARK: - User Level System
    
    enum UserLevel: String, CaseIterable {
        case novice = "Novice Questioner"
        case apprentice = "Apprentice Skeptic"
        case journeyman = "Journeyman Thinker"
        case expert = "Expert Contrarian"
        case master = "Master Philosopher"
        case legend = "Legendary Maverick"
        
        var requiredXP: Int {
            switch self {
            case .novice: return 0
            case .apprentice: return 100
            case .journeyman: return 300
            case .expert: return 600
            case .master: return 1000
            case .legend: return 1500
            }
        }
        
        var color: Color {
            switch self {
            case .novice: return Color.gray
            case .apprentice: return Color(red: 0.26, green: 0.62, blue: 0.95)
            case .journeyman: return Color(red: 0.95, green: 0.77, blue: 0.06)
            case .expert: return Color(red: 0.95, green: 0.42, blue: 0.26)
            case .master: return Color(red: 0.91, green: 0.12, blue: 0.39)
            case .legend: return Color(red: 0.58, green: 0.42, blue: 0.94)
            }
        }
        
        var icon: String {
            switch self {
            case .novice: return "studentdesk"
            case .apprentice: return "book.fill"
            case .journeyman: return "brain"
            case .expert: return "crown"
            case .master: return "star.circle.fill"
            case .legend: return "infinity"
            }
        }
        
        func nextLevel() -> UserLevel? {
            switch self {
            case .novice: return .apprentice
            case .apprentice: return .journeyman
            case .journeyman: return .expert
            case .expert: return .master
            case .master: return .legend
            case .legend: return nil
            }
        }
    }
    
    // MARK: - Emotional Journey Stages
    
    enum EmotionalJourneyStage: String, CaseIterable {
        case curiosity = "Awakening Curiosity"
        case questioning = "Active Questioning"
        case challenging = "Challenging Assumptions"
        case discovering = "Deep Discovery"
        case transforming = "Mental Transformation"
        case mastering = "Intellectual Mastery"
        
        var description: String {
            switch self {
            case .curiosity: return "Your mind is opening to new possibilities"
            case .questioning: return "You're beginning to question everything"
            case .challenging: return "You actively challenge conventional wisdom"
            case .discovering: return "Each truth reveals deeper layers of reality"
            case .transforming: return "Your worldview is fundamentally shifting"
            case .mastering: return "You've transcended conventional thinking"
            }
        }
        
        var milestone: Int {
            switch self {
            case .curiosity: return 0
            case .questioning: return 10
            case .challenging: return 30
            case .discovering: return 60
            case .transforming: return 100
            case .mastering: return 200
            }
        }
    }
    
    // MARK: - Achievement System
    
    struct UnlockedAchievement: Codable, Identifiable {
        let id: String
        let name: String
        let description: String
        let iconName: String
        let unlockedDate: Date
        let rarity: AchievementRarity
        
        enum AchievementRarity: String, Codable {
            case common, rare, epic, legendary
            
            var color: Color {
                switch self {
                case .common: return .gray
                case .rare: return Color(red: 0.26, green: 0.62, blue: 0.95)
                case .epic: return Color(red: 0.58, green: 0.42, blue: 0.94)
                case .legendary: return Color(red: 0.95, green: 0.77, blue: 0.06)
                }
            }
        }
    }
    
    // MARK: - Core Functions
    
    func checkDailyVisit() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastVisit = lastVisitDate {
            let lastVisitDay = calendar.startOfDay(for: lastVisit)
            let daysDifference = calendar.dateComponents([.day], from: lastVisitDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Same day visit - continue
                return
            } else if daysDifference == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
                totalDaysEngaged += 1
                dailyDiscoveries = 0
                shouldShowDailyWisdom = true
                
                // Check for streak achievements
                checkStreakAchievements()
                
                // Update longest streak
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                    awardExperience(50, reason: "New longest streak!")
                }
            } else {
                // Streak broken
                if currentStreak > 0 {
                    handleStreakBreak()
                }
                currentStreak = 1
                totalDaysEngaged += 1
                dailyDiscoveries = 0
                shouldShowDailyWisdom = true
            }
        } else {
            // First visit
            currentStreak = 1
            totalDaysEngaged = 1
            dailyDiscoveries = 0
            shouldShowDailyWisdom = true
            
            // Award first visit achievement
            unlockAchievement(
                id: "first_visit",
                name: "Welcome, Contrarian",
                description: "Begin your intellectual journey",
                iconName: "door.left.hand.open",
                rarity: .common
            )
        }
        
        lastVisitDate = Date()
        saveUserJourney()
    }
    
    func recordDiscovery() {
        dailyDiscoveries += 1
        weeklyProgress += 1
        
        // Award experience points
        awardExperience(10, reason: "Discovery")
        
        // Check for discovery milestones
        checkDiscoveryMilestones()
        
        // Update emotional journey stage
        updateEmotionalJourney()
        
        // Check weekly goal
        if weeklyProgress >= weeklyGoal {
            completeWeeklyGoal()
        }
        
        saveUserJourney()
    }
    
    func awardExperience(_ points: Int, reason: String) {
        experiencePoints += points
        
        // Check for level up
        if let nextLevel = userLevel.nextLevel() {
            if experiencePoints >= nextLevel.requiredXP {
                levelUp(to: nextLevel)
            }
        }
        
        saveUserJourney()
    }
    
    private func levelUp(to newLevel: UserLevel) {
        userLevel = newLevel
        
        // Award level up achievement
        unlockAchievement(
            id: "level_\(newLevel.rawValue)",
            name: "Reached \(newLevel.rawValue)",
            description: "Your intellectual prowess grows",
            iconName: newLevel.icon,
            rarity: newLevel == .legend ? .legendary : newLevel == .master ? .epic : .rare
        )
        
        // Bonus XP for leveling up
        awardExperience(100, reason: "Level Up Bonus!")
    }
    
    private func updateEmotionalJourney() {
        let totalDiscoveries = UserDefaults.standard.integer(forKey: "totalDiscoveries")
        
        for stage in EmotionalJourneyStage.allCases.reversed() {
            if totalDiscoveries >= stage.milestone {
                if emotionalJourneyStage != stage {
                    emotionalJourneyStage = stage
                    
                    // Award emotional milestone achievement
                    unlockAchievement(
                        id: "emotional_\(stage.rawValue)",
                        name: stage.rawValue,
                        description: stage.description,
                        iconName: "heart.text.square.fill",
                        rarity: stage == .mastering ? .legendary : .epic
                    )
                }
                break
            }
        }
    }
    
    // MARK: - Achievement Checking
    
    private func checkStreakAchievements() {
        switch currentStreak {
        case 3:
            unlockAchievement(
                id: "streak_3",
                name: "Triduum",
                description: "3 day streak",
                iconName: "flame.fill",
                rarity: .common
            )
        case 7:
            unlockAchievement(
                id: "streak_7",
                name: "Week Warrior",
                description: "7 day streak",
                iconName: "flame.circle.fill",
                rarity: .rare
            )
        case 30:
            unlockAchievement(
                id: "streak_30",
                name: "Monthly Master",
                description: "30 day streak",
                iconName: "flame.circle.fill",
                rarity: .epic
            )
        case 100:
            unlockAchievement(
                id: "streak_100",
                name: "Centurion",
                description: "100 day streak",
                iconName: "flame.circle.fill",
                rarity: .legendary
            )
        default:
            break
        }
    }
    
    private func checkDiscoveryMilestones() {
        let totalDiscoveries = UserDefaults.standard.integer(forKey: "totalDiscoveries")
        
        switch totalDiscoveries {
        case 1:
            unlockAchievement(
                id: "first_discovery",
                name: "First Truth",
                description: "Your first contrarian insight",
                iconName: "lightbulb.fill",
                rarity: .common
            )
        case 10:
            unlockAchievement(
                id: "discovery_10",
                name: "Truth Seeker",
                description: "10 discoveries made",
                iconName: "magnifyingglass.circle.fill",
                rarity: .common
            )
        case 50:
            unlockAchievement(
                id: "discovery_50",
                name: "Knowledge Hunter",
                description: "50 discoveries made",
                iconName: "book.circle.fill",
                rarity: .rare
            )
        case 100:
            unlockAchievement(
                id: "discovery_100",
                name: "Wisdom Collector",
                description: "100 discoveries made",
                iconName: "brain",
                rarity: .epic
            )
        case 500:
            unlockAchievement(
                id: "discovery_500",
                name: "Omniscient",
                description: "500 discoveries made",
                iconName: "eye.circle.fill",
                rarity: .legendary
            )
        default:
            break
        }
        
        // Daily discovery achievements
        switch dailyDiscoveries {
        case 5:
            unlockAchievement(
                id: "daily_5",
                name: "Daily Dedication",
                description: "5 discoveries in one day",
                iconName: "sun.max.fill",
                rarity: .common
            )
        case 10:
            unlockAchievement(
                id: "daily_10",
                name: "Information Hungry",
                description: "10 discoveries in one day",
                iconName: "sun.max.circle.fill",
                rarity: .rare
            )
        case 20:
            unlockAchievement(
                id: "daily_20",
                name: "Insatiable Mind",
                description: "20 discoveries in one day",
                iconName: "sun.max.trianglebadge.exclamationmark",
                rarity: .epic
            )
        default:
            break
        }
    }
    
    private func completeWeeklyGoal() {
        unlockAchievement(
            id: "weekly_goal_\(Date().timeIntervalSince1970)",
            name: "Weekly Champion",
            description: "Completed weekly discovery goal",
            iconName: "checkmark.seal.fill",
            rarity: .rare
        )
        
        awardExperience(100, reason: "Weekly Goal Complete!")
        
        // Reset weekly progress
        weeklyProgress = 0
        userDefaults.set(Date(), forKey: weekStartKey)
    }
    
    private func handleStreakBreak() {
        // Emotional feedback for breaking streak
        if currentStreak >= 7 {
            // Only penalize for significant streaks
            experiencePoints = max(0, experiencePoints - 20)
        }
    }
    
    func unlockAchievement(id: String, name: String, description: String, iconName: String, rarity: UnlockedAchievement.AchievementRarity) {
        // Check if already unlocked
        if achievementHistory.contains(where: { $0.id == id }) {
            return
        }
        
        let achievement = UnlockedAchievement(
            id: id,
            name: name,
            description: description,
            iconName: iconName,
            unlockedDate: Date(),
            rarity: rarity
        )
        
        achievementHistory.append(achievement)
        
        // Award XP based on rarity
        let xpReward: Int
        switch rarity {
        case .common: xpReward = 25
        case .rare: xpReward = 50
        case .epic: xpReward = 100
        case .legendary: xpReward = 200
        }
        
        awardExperience(xpReward, reason: "Achievement: \(name)")
        saveAchievements()
    }
    
    // MARK: - Persistence
    
    private func loadUserJourney() {
        currentStreak = userDefaults.integer(forKey: streakKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)
        totalDaysEngaged = userDefaults.integer(forKey: totalDaysKey)
        dailyDiscoveries = userDefaults.integer(forKey: dailyDiscoveriesKey)
        weeklyProgress = userDefaults.integer(forKey: weeklyProgressKey)
        experiencePoints = userDefaults.integer(forKey: experienceKey)
        
        if let lastVisit = userDefaults.object(forKey: lastVisitKey) as? Date {
            lastVisitDate = lastVisit
        }
        
        if let levelString = userDefaults.string(forKey: levelKey),
           let level = UserLevel(rawValue: levelString) {
            userLevel = level
        }
        
        if let stageString = userDefaults.string(forKey: emotionalStageKey),
           let stage = EmotionalJourneyStage(rawValue: stageString) {
            emotionalJourneyStage = stage
        }
        
        loadAchievements()
        checkWeeklyReset()
    }
    
    private func saveUserJourney() {
        userDefaults.set(currentStreak, forKey: streakKey)
        userDefaults.set(longestStreak, forKey: longestStreakKey)
        userDefaults.set(totalDaysEngaged, forKey: totalDaysKey)
        userDefaults.set(lastVisitDate, forKey: lastVisitKey)
        userDefaults.set(dailyDiscoveries, forKey: dailyDiscoveriesKey)
        userDefaults.set(weeklyProgress, forKey: weeklyProgressKey)
        userDefaults.set(experiencePoints, forKey: experienceKey)
        userDefaults.set(userLevel.rawValue, forKey: levelKey)
        userDefaults.set(emotionalJourneyStage.rawValue, forKey: emotionalStageKey)
    }
    
    private func loadAchievements() {
        if let data = userDefaults.data(forKey: achievementsKey),
           let achievements = try? JSONDecoder().decode([UnlockedAchievement].self, from: data) {
            achievementHistory = achievements
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievementHistory) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }
    
    private func checkWeeklyReset() {
        let calendar = Calendar.current
        if let weekStart = userDefaults.object(forKey: weekStartKey) as? Date {
            let weeksSince = calendar.dateComponents([.weekOfYear], from: weekStart, to: Date()).weekOfYear ?? 0
            if weeksSince > 0 {
                weeklyProgress = 0
                userDefaults.set(Date(), forKey: weekStartKey)
            }
        } else {
            userDefaults.set(Date(), forKey: weekStartKey)
        }
    }
    
    private func checkStreakStatus() {
        guard let lastVisit = lastVisitDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastVisitDay = calendar.startOfDay(for: lastVisit)
        let daysDifference = calendar.dateComponents([.day], from: lastVisitDay, to: today).day ?? 0
        
        if daysDifference > 1 {
            // Streak is broken
            currentStreak = 0
            saveUserJourney()
        }
    }
    
    // MARK: - Computed Properties
    
    var streakIntensity: Double {
        switch currentStreak {
        case 0: return 0
        case 1...3: return 0.3
        case 4...7: return 0.5
        case 8...14: return 0.7
        case 15...30: return 0.85
        default: return 1.0
        }
    }
    
    var progressToNextLevel: Double {
        guard let nextLevel = userLevel.nextLevel() else { return 1.0 }
        let currentLevelXP = userLevel.requiredXP
        let nextLevelXP = nextLevel.requiredXP
        let progressXP = experiencePoints - currentLevelXP
        let requiredXP = nextLevelXP - currentLevelXP
        return Double(progressXP) / Double(requiredXP)
    }
    
    func dismissDailyWisdom() {
        shouldShowDailyWisdom = false
    }
}