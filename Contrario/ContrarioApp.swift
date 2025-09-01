//
//  ContrarioApp.swift
//  Contrario
//
//  Created by Tono Murrieta  on 23/07/25.
//

import SwiftUI

@main
struct ContrarioApp: App {
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var factsManager = ContraryFactsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favoritesManager)
                .environmentObject(settingsManager)
                .environmentObject(factsManager)
                .preferredColorScheme(settingsManager.isDarkMode ? .dark : .light)
        }
    }
}