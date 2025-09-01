import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingAbout = false
    
    var body: some View {
        ZStack {
            // Consistent dark gradient background matching HomeView and NewsView
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
                // Header matching HomeView style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Customize your experience")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Preferences Section
                        VStack(spacing: 12) {
                            Text("PREFERENCES")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                            
                            // Dark Mode Toggle
                            SettingRow(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                toggle: $settingsManager.isDarkMode
                            )
                            
                            // Notifications Toggle
                            SettingRow(
                                icon: "bell.fill",
                                title: "Daily Facts",
                                toggle: $settingsManager.notificationsEnabled
                            )
                            
                            // Notification Time (conditional)
                            if settingsManager.notificationsEnabled {
                                SettingTimeRow(
                                    icon: "clock.fill",
                                    title: "Notification Time",
                                    time: $settingsManager.dailyFactTime
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.bottom, 30)
                        
                        // About Section
                        VStack(spacing: 12) {
                            Text("ABOUT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Version")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("1.0")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                )
                                
                                HStack {
                                    Text("Developer")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("Contrario Team")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 50)
                        
                        // App Branding
                        VStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                            
                            Text("Contrario")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Challenge your thinking")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .preferredColorScheme(settingsManager.isDarkMode ? .dark : .light)
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var toggle: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Toggle("", isOn: $toggle)
                .labelsHidden()
                .tint(Color(red: 0.95, green: 0.77, blue: 0.06))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - Setting Time Row Component
struct SettingTimeRow: View {
    let icon: String
    let title: String
    @Binding var time: Date
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .accentColor(Color(red: 0.95, green: 0.77, blue: 0.06))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
}