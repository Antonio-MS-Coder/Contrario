import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    @Published var dailyFactTime: Date {
        didSet {
            UserDefaults.standard.set(dailyFactTime, forKey: "dailyFactTime")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        if let savedTime = UserDefaults.standard.object(forKey: "dailyFactTime") as? Date {
            self.dailyFactTime = savedTime
        } else {
            // Default to 9:00 AM
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            self.dailyFactTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
    }
}