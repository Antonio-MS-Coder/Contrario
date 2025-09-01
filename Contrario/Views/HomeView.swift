import SwiftUI

struct HomeView: View {
    @EnvironmentObject var factsManager: ContraryFactsManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var progressManager = UserProgressManager()
    
    @State private var currentFactIndex = 0
    @State private var cardOffset: CGSize = .zero
    @State private var showingShareSheet = false
    @State private var shareItem: ContraryFact?
    
    // MARK: - Performance Optimization: Memoized Properties
    private var currentFact: ContraryFact? {
        guard currentFactIndex < factsManager.facts.count else { return nil }
        return factsManager.facts[currentFactIndex]
    }
    
    private var isCurrentFactFavorite: Bool {
        guard let fact = currentFact else { return false }
        return favoritesManager.isFavorite(fact)
    }
    
    var userName: String {
        UserDefaults.standard.string(forKey: "userName") ?? ""
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "" : ", \(userName)"
        
        switch hour {
        case 5..<12:
            return "Good morning\(name)"
        case 12..<17:
            return "Good afternoon\(name)"
        case 17..<22:
            return "Good evening\(name)"
        default:
            return "Hello\(name)"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean gradient background
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
                    // Minimal header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(greeting)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Challenge your thinking")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                            
                            // Subtle streak indicator
                            if progressManager.userProgress.totalDiscovered > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                                    Text("\(progressManager.userProgress.totalDiscovered)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // Main content area
                    GeometryReader { geometry in
                        if !factsManager.facts.isEmpty {
                            ZStack {
                                // Optimized: Limit background cards to 2 for performance
                                ForEach(0..<min(2, factsManager.facts.count), id: \.self) { index in
                                    if currentFactIndex + index < factsManager.facts.count {
                                        MinimalFactCard(
                                            fact: factsManager.facts[currentFactIndex + index],
                                            isFavorite: favoritesManager.isFavorite(factsManager.facts[currentFactIndex + index]),
                                            isTopCard: index == 0,
                                            progressManager: progressManager
                                        )
                                        .offset(y: CGFloat(index) * 8) // Reduced offset for better performance
                                        .scaleEffect(1 - (CGFloat(index) * 0.02)) // Reduced scale effect
                                        .opacity(index == 0 ? 1 : 0.7)
                                        .zIndex(Double(2 - index))
                                    }
                                }
                                
                                // Top interactive card - Optimized with memoized properties
                                if let currentFact = currentFact {
                                    MinimalFactCard(
                                        fact: currentFact,
                                        isFavorite: isCurrentFactFavorite,
                                        isTopCard: true,
                                        progressManager: progressManager
                                    )
                                    .offset(cardOffset)
                                    .rotationEffect(.degrees(Double(cardOffset.width) / 20))
                                    .gesture(createSwipeGesture(for: currentFact))
                                    .zIndex(10)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // Loading or empty state
                            VStack(spacing: 20) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                
                                Text("Loading contrarian wisdom...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    
                    // Minimal action buttons
                    HStack(spacing: 40) {
                        // Refresh
                        Button(action: {
                            factsManager.getRandomFact()
                            currentFactIndex = 0
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Favorite - Optimized with memoized properties
                        Button(action: {
                            guard let fact = currentFact else { return }
                            if isCurrentFactFavorite {
                                favoritesManager.removeFavorite(fact)
                            } else {
                                favoritesManager.addFavorite(fact)
                            }
                        }) {
                            Image(systemName: isCurrentFactFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isCurrentFactFavorite ? 
                                    Color(red: 0.91, green: 0.12, blue: 0.39) : .white.opacity(0.6))
                        }
                        .disabled(currentFact == nil)
                        
                        // Share - Optimized
                        Button(action: {
                            guard let fact = currentFact else { return }
                            shareItem = fact
                            showingShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .disabled(currentFact == nil)
                    }
                    .padding(.vertical, 30)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingShareSheet) {
                if let fact = shareItem {
                    FactShareSheet(fact: fact)
                }
            }
        }
    }
    
    // MARK: - Performance Optimization: Extracted Gesture
    private func createSwipeGesture(for fact: ContraryFact) -> some Gesture {
        DragGesture()
            .onChanged { value in
                cardOffset = value.translation
            }
            .onEnded { value in
                handleSwipeGesture(with: value, for: fact)
            }
    }
    
    private func handleSwipeGesture(with value: DragGesture.Value, for fact: ContraryFact) {
        if abs(value.translation.width) > 100 {
            // Swipe action
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                cardOffset = CGSize(
                    width: value.translation.width > 0 ? 500 : -500,
                    height: 0
                )
            }
            
            // Mark as discovered
            progressManager.markFactAsDiscovered(fact)
            
            // Move to next fact with optimized timing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                cardOffset = .zero
                if currentFactIndex < factsManager.facts.count - 1 {
                    currentFactIndex += 1
                } else {
                    currentFactIndex = 0
                }
            }
        } else {
            // Snap back with optimized spring animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardOffset = .zero
            }
        }
    }
}

// MARK: - Fact Card Component
struct MinimalFactCard: View {
    let fact: ContraryFact
    let isFavorite: Bool
    let isTopCard: Bool
    let progressManager: UserProgressManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Category badge
            HStack {
                Text(fact.category.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.15))
                    )
                
                Spacer()
                
                if !fact.source.isEmpty {
                    Text(fact.source)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            // Main fact
            Text(fact.text)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
            
            // Contrarian insight
            if !fact.contraryInsight.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CONTRARIAN INSIGHT")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(fact.contraryInsight)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                        .italic()
                }
            }
            
            Spacer()
            
            // Swipe hint (only on top card)
            if isTopCard {
                HStack {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12))
                    Text("Swipe to explore")
                        .font(.system(size: 12))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(.white.opacity(0.3))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
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
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
}

// MARK: - Share Sheet
struct FactShareSheet: UIViewControllerRepresentable {
    let fact: ContraryFact
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let text = """
        💭 \(fact.text)
        
        💡 \(fact.contraryInsight)
        
        🧠 Discovered via Contrario
        📱 Challenge your thinking with Contrario
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}