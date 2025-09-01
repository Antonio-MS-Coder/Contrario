import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    @Published var favorites: [ContraryFact] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favoritesFacts"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([ContraryFact].self, from: data) {
            favorites = decoded
        }
    }
    
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            userDefaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func addFavorite(_ fact: ContraryFact) {
        if !favorites.contains(where: { $0.id == fact.id }) {
            favorites.append(fact)
            saveFavorites()
        }
    }
    
    func removeFavorite(_ fact: ContraryFact) {
        favorites.removeAll { $0.id == fact.id }
        saveFavorites()
    }
    
    func isFavorite(_ fact: ContraryFact) -> Bool {
        return favorites.contains(where: { $0.id == fact.id })
    }
    
    func toggleFavorite(_ fact: ContraryFact) {
        if isFavorite(fact) {
            removeFavorite(fact)
        } else {
            addFavorite(fact)
        }
    }
}