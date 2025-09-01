import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Reliable gradient background with fallback colors
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.98, blue: 0.97),
                        Color(red: 0.94, green: 0.94, blue: 0.93)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                        .padding(.top)
                    
                    VStack(spacing: 16) {
                        // Dark Mode Toggle
                        HStack {
                            Label("Dark Mode", systemImage: "moon.fill")
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                            
                            Spacer()
                            
                            Toggle("", isOn: $settingsManager.isDarkMode)
                                .labelsHidden()
                                .tint(Color(red: 0.59, green: 0.40, blue: 0.27))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        // Notifications Toggle
                        HStack {
                            Label("Daily Facts", systemImage: "bell.fill")
                                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                            
                            Spacer()
                            
                            Toggle("", isOn: $settingsManager.notificationsEnabled)
                                .labelsHidden()
                                .tint(Color(red: 0.59, green: 0.40, blue: 0.27))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        
                        // Notification Time
                        if settingsManager.notificationsEnabled {
                            HStack {
                                Label("Notification Time", systemImage: "clock.fill")
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                                
                                Spacer()
                                
                                DatePicker("", selection: $settingsManager.dailyFactTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // About Section
                    VStack(spacing: 10) {
                        Text("Contrario")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                        
                        Text("Think Different")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50))
                        
                        Text("Version 1.0")
                            .font(.caption2)
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50).opacity(0.7))
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(settingsManager.isDarkMode ? .dark : .light)
    }
}