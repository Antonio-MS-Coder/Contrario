import SwiftUI

// Force widget to recalculate colors by creating a unique identifier
struct WidgetColorScheme {
    static var current: ColorScheme {
        SharedDataManager.isDarkMode() ? .dark : .light
    }
}

extension Color {
    static var widgetBackground: LinearGradient {
        let isDarkMode = SharedDataManager.isDarkMode()
        return LinearGradient(
            colors: isDarkMode ? 
                [Color(red: 0.11, green: 0.11, blue: 0.11), Color(red: 0.07, green: 0.07, blue: 0.07)] :
                [Color(red: 0.98, green: 0.97, blue: 0.95), Color(red: 0.95, green: 0.92, blue: 0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var widgetPrimaryText: Color {
        let isDarkMode = SharedDataManager.isDarkMode()
        return isDarkMode ? .white : Color(red: 0.3, green: 0.25, blue: 0.2)
    }
    
    static var widgetSecondaryText: Color {
        let isDarkMode = SharedDataManager.isDarkMode()
        return isDarkMode ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.3, green: 0.25, blue: 0.2)
    }
    
    static var widgetAccentBrown: Color {
        let isDarkMode = SharedDataManager.isDarkMode()
        return isDarkMode ? Color(red: 0.55, green: 0.45, blue: 0.35) : Color(red: 0.7, green: 0.6, blue: 0.5)
    }
    
    static var widgetSubtitleText: Color {
        let isDarkMode = SharedDataManager.isDarkMode()
        return isDarkMode ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.6, green: 0.5, blue: 0.4).opacity(0.8)
    }
    
    // High contrast colors for lock screen widgets
    static var lockScreenPrimaryText: Color {
        Color(red: 0.1, green: 0.1, blue: 0.1)  // Very dark gray for maximum contrast
    }
    
    static var lockScreenSecondaryText: Color {
        Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.9)  // Slightly lighter but still high contrast
    }
    
    static var lockScreenBackground: Color {
        Color.white.opacity(0.85)  // Semi-transparent white background
    }
    
    static var lockScreenAccent: Color {
        Color(red: 0.5, green: 0.4, blue: 0.3)  // Darker brown for better contrast
    }
}