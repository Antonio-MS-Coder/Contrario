//
//  ContentView.swift
//  Contrario
//
//  Created by Tono Murrieta  on 23/07/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var factsManager: ContraryFactsManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedTab = 0
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    @State private var showOnboarding = false
    
    init() {
        // Configure tab bar appearance immediately on init
        setupTabBarAppearance()
    }
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Workout", systemImage: "brain.head.profile")
                        }
                        .tag(0)
                    
                    NewsView()
                        .tabItem {
                            Label("News", systemImage: "doc.text")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(2)
                }
                .tint(Color(red: 0.95, green: 0.77, blue: 0.06))
            }
        }
        .preferredColorScheme(.dark) // Force dark mode for consistency
        .onAppear {
            // Check if this is first launch
            if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasLaunchedBefore) {
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasLaunchedBefore)
                showOnboarding = true
            }
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Dark background matching the app theme
        appearance.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1.0)
        
        // Remove any shadow or border
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        // Configure unselected items
        let normalItemAppearance = UITabBarItemAppearance()
        normalItemAppearance.normal.iconColor = UIColor(white: 0.7, alpha: 1.0)
        normalItemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.7, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Configure selected items  
        normalItemAppearance.selected.iconColor = UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)
        normalItemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Apply to all item positions
        appearance.stackedLayoutAppearance = normalItemAppearance
        appearance.inlineLayoutAppearance = normalItemAppearance
        appearance.compactInlineLayoutAppearance = normalItemAppearance
        
        // Apply globally
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Additional settings for consistency
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1.0)
        UITabBar.appearance().unselectedItemTintColor = UIColor(white: 0.7, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)
    }
}