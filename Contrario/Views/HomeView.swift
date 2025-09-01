import SwiftUI

struct HomeView: View {
    @EnvironmentObject var factsManager: ContraryFactsManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var progressManager = UserProgressManager()
    
    @State private var currentFactIndex = 0
    @State private var cardOffset: CGSize = .zero
    @State private var showingShareSheet = false
    @State private var shareItem: ContraryFact?
    
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
                                // Background cards (stack effect)
                                ForEach(0..<min(3, factsManager.facts.count), id: \.self) { index in
                                    if currentFactIndex + index < factsManager.facts.count {
                                        MinimalFactCard(
                                            fact: factsManager.facts[currentFactIndex + index],
                                            isFavorite: favoritesManager.isFavorite(factsManager.facts[currentFactIndex + index]),
                                            isTopCard: index == 0,
                                            progressManager: progressManager
                                        )
                                        .offset(y: CGFloat(index) * 10)
                                        .scaleEffect(1 - (CGFloat(index) * 0.03))
                                        .opacity(index == 0 ? 1 : 0.8)
                                        .zIndex(Double(3 - index))
                                    }
                                }
                                
                                // Top interactive card
                                if currentFactIndex < factsManager.facts.count {
                                    MinimalFactCard(
                                        fact: factsManager.facts[currentFactIndex],
                                        isFavorite: favoritesManager.isFavorite(factsManager.facts[currentFactIndex]),
                                        isTopCard: true,
                                        progressManager: progressManager
                                    )
                                    .offset(cardOffset)
                                    .rotationEffect(.degrees(Double(cardOffset.width) / 20))
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                cardOffset = value.translation
                                            }
                                            .onEnded { value in
                                                if abs(value.translation.width) > 100 {
                                                    // Swipe action
                                                    withAnimation(.spring()) {
                                                        cardOffset = CGSize(
                                                            width: value.translation.width > 0 ? 500 : -500,
                                                            height: 0
                                                        )
                                                    }
                                                    
                                                    // Mark as discovered
                                                    progressManager.markFactAsDiscovered(factsManager.facts[currentFactIndex])
                                                    
                                                    // Move to next fact
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        cardOffset = .zero
                                                        if currentFactIndex < factsManager.facts.count - 1 {
                                                            currentFactIndex += 1
                                                        } else {
                                                            currentFactIndex = 0
                                                        }
                                                    }
                                                } else {
                                                    // Snap back
                                                    withAnimation(.spring()) {
                                                        cardOffset = .zero
                                                    }
                                                }
                                            }
                                    )
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
                        
                        // Favorite
                        Button(action: {
                            if currentFactIndex < factsManager.facts.count {
                                let fact = factsManager.facts[currentFactIndex]
                                if favoritesManager.isFavorite(fact) {
                                    favoritesManager.removeFavorite(fact)
                                } else {
                                    favoritesManager.addFavorite(fact)
                                }
                            }
                        }) {
                            Image(systemName: favoritesManager.isFavorite(factsManager.facts.isEmpty ? 
                                ContraryFact(text: "", category: "", source: "", contraryInsight: "") : 
                                factsManager.facts[currentFactIndex]) ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(favoritesManager.isFavorite(factsManager.facts.isEmpty ? 
                                    ContraryFact(text: "", category: "", source: "", contraryInsight: "") : 
                                    factsManager.facts[currentFactIndex]) ? 
                                    Color(red: 0.91, green: 0.12, blue: 0.39) : .white.opacity(0.6))
                        }
                        .disabled(factsManager.facts.isEmpty)
                        
                        // Share
                        Button(action: {
                            if currentFactIndex < factsManager.facts.count {
                                shareItem = factsManager.facts[currentFactIndex]
                                showingShareSheet = true
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .disabled(factsManager.facts.isEmpty)
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