//
//  ContentView.swift
//  Contrario
//
//  Created by Tono Murrieta  on 23/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var factsManager: ContraryFactsManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedTab = 0
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: "brain.head.profile")
                            Text("Workout")
                        }
                        .tag(0)
                    
                    CategoriesView()
                        .tabItem {
                            Image(systemName: "network")
                            Text("Explore")
                        }
                        .tag(1)
                    
                    NewsView()
                        .tabItem {
                            Image(systemName: "eye.fill")
                            Text("Lens")
                        }
                        .tag(2)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(3)
                }
                .accentColor(Color("AccentBrown"))
            }
        }
        .onAppear {
            // Check if this is first launch
            if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasLaunchedBefore) {
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasLaunchedBefore)
                showOnboarding = true
            }
        }
    }
}