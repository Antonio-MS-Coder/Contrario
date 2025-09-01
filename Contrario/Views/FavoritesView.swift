import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var factsManager: ContraryFactsManager
    @State private var showShareSheet = false
    @State private var selectedFact: ContraryFact?
    @State private var factToRemove: ContraryFact?
    @State private var showRemoveConfirmation = false
    @State private var showClearAllConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Reliable gradient background with fallback colors
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.98, blue: 0.97),  // Light mode fallback
                        Color(red: 0.94, green: 0.94, blue: 0.93)   // Light mode fallback
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if favoritesManager.favorites.isEmpty {
                    // Empty state with enhanced visibility
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50).opacity(0.6))
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                        
                        Text("Tap the heart icon on facts you love")
                            .font(.body)
                            .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header with clear all button
                            HStack {
                                Text("Your Favorites")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                                
                                Spacer()
                                
                                if favoritesManager.favorites.count > 1 {
                                    Button(action: {
                                        HapticManager.shared.impact(style: .light)
                                        showClearAllConfirmation = true
                                    }) {
                                        Text("Clear All")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(red: 0.59, green: 0.40, blue: 0.27))
                                    }
                                    .accessibilityLabel("Clear all favorites")
                                    .accessibilityHint("Remove all saved facts from your favorites")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Favorites count
                            HStack {
                                Text("\(favoritesManager.favorites.count) saved fact\(favoritesManager.favorites.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50))
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Favorites list
                            ForEach(favoritesManager.favorites, id: \.id) { fact in
                                FavoriteFactCard(fact: fact) {
                                    selectedFact = fact
                                    showShareSheet = true
                                } onRemove: {
                                    HapticManager.shared.impact(style: .light)
                                    factToRemove = fact
                                    showRemoveConfirmation = true
                                }
                                .padding(.horizontal)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showShareSheet) {
                if let fact = selectedFact {
                    ShareSheet(items: [createShareText(for: fact)])
                }
            }
            .confirmationDialog(
                "Remove from favorites?",
                isPresented: $showRemoveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    if let fact = factToRemove {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            favoritesManager.removeFavorite(fact)
                            HapticManager.shared.notification(type: .warning)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let fact = factToRemove {
                    Text("Remove \"\(String(fact.text.prefix(50)))...\" from favorites?")
                }
            }
            .confirmationDialog(
                "Clear all favorites?",
                isPresented: $showClearAllConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        favoritesManager.favorites.removeAll()
                        favoritesManager.saveFavorites()
                        HapticManager.shared.notification(type: .warning)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all \(favoritesManager.favorites.count) saved facts from your favorites.")
            }
        }
    }
    
    private func createShareText(for fact: ContraryFact) -> String {
        var shareText = "\(fact.text)\n\n"
        if !fact.contraryInsight.isEmpty {
            shareText += "💡 \(fact.contraryInsight)\n\n"
        }
        if !fact.source.isEmpty {
            shareText += "— \(fact.source)\n\n"
        }
        shareText += "Shared from Contrario app"
        return shareText
    }
}

struct FavoriteFactCard: View {
    let fact: ContraryFact
    let onShare: () -> Void
    let onRemove: () -> Void
    @EnvironmentObject var factsManager: ContraryFactsManager
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack {
                Image(systemName: factsManager.getCategoryIcon(fact.category))
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.59, green: 0.40, blue: 0.27))
                
                Text(factsManager.formatCategoryName(fact.category))
                    .font(.caption)
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50))
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.87, green: 0.18, blue: 0.31))
                        .scaleEffect(isPressed ? 0.8 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                }
                .accessibilityLabel("Remove from favorites")
                .accessibilityHint("Double tap to remove this fact from your favorites")
                .onTapGesture {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                    onRemove()
                }
            }
            
            // Fact text
            Text(fact.text)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.11, green: 0.11, blue: 0.13))
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .accessibilityLabel("Saved fact: \(fact.text)")
            
            // Insight
            if !fact.contraryInsight.isEmpty {
                Text("💡 \(fact.contraryInsight)")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50))
                    .lineLimit(2)
            }
            
            // Bottom row with source and share
            HStack {
                if !fact.source.isEmpty {
                    Text("— \(fact.source)")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.50).opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.impact(style: .light)
                    onShare()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.59, green: 0.40, blue: 0.27))
                        .padding(8)
                        .background(Color(red: 0.59, green: 0.40, blue: 0.27).opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Share fact")
                .accessibilityHint("Share this contrarian fact with others")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}