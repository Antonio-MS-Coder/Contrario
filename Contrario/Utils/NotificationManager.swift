import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    @Published var isNotificationEnabled = false
    @Published var notificationTime = Date()
    
    private let userDefaults = UserDefaults.standard
    private let notificationEnabledKey = "notificationEnabled"
    private let notificationTimeKey = "notificationTime"
    
    init() {
        isNotificationEnabled = userDefaults.bool(forKey: notificationEnabledKey)
        if let savedTime = userDefaults.object(forKey: notificationTimeKey) as? Date {
            notificationTime = savedTime
        } else {
            // Default to 9 AM
            var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
            components.hour = 9
            components.minute = 0
            notificationTime = Calendar.current.date(from: components) ?? Date()
        }
        
        // Check current authorization status
        checkNotificationStatus()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isNotificationEnabled = granted
                if granted {
                    self?.scheduleNotifications()
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func toggleNotifications() {
        if isNotificationEnabled {
            // Turn off notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            isNotificationEnabled = false
            userDefaults.set(false, forKey: notificationEnabledKey)
        } else {
            // Request permission and turn on
            requestNotificationPermission()
            userDefaults.set(true, forKey: notificationEnabledKey)
        }
    }
    
    func updateNotificationTime(_ newTime: Date) {
        notificationTime = newTime
        userDefaults.set(newTime, forKey: notificationTimeKey)
        
        if isNotificationEnabled {
            // Reschedule with new time
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            scheduleNotifications()
        }
    }
    
    func scheduleNotifications() {
        let facts = [
            ("Competition is for losers - monopolies drive progress", "Business"),
            ("The best startup ideas seem like bad ideas at first", "Innovation"),
            ("Perfectionism is a form of procrastination", "Philosophy"),
            ("The future is already here, it's just not evenly distributed", "Future"),
            ("Working harder is often less effective than working less", "Productivity"),
            ("The most contrarian thing is to think for yourself", "Philosophy"),
            ("Being first to market is overrated", "Business"),
            ("Transparency can reduce trust", "Society"),
            ("The best leaders are often introverts", "Leadership"),
            ("Small teams outperform large teams", "Business"),
            ("The best code is no code", "Technology"),
            ("Constraints breed creativity", "Innovation"),
            ("The sharing economy isn't about sharing", "Economics"),
            ("Social networks make us less social", "Society")
        ]
        
        // Schedule notifications for the next 30 days
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        
        for dayOffset in 0..<30 {
            guard let notificationDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
            dateComponents.hour = components.hour
            dateComponents.minute = components.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let randomFact = facts.randomElement() ?? facts[0]
            let content = UNMutableNotificationContent()
            content.title = "Contrarian Insight"
            content.body = randomFact.0
            content.sound = .default
            content.badge = 1
            
            let request = UNNotificationRequest(
                identifier: "daily-fact-\(dayOffset)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}