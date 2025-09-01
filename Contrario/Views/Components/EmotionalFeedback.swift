import SwiftUI
import AVFoundation

// MARK: - Celebration Effects
struct CelebrationEffect: View {
    let type: CelebrationType
    @State private var isAnimating = false
    @State private var particles: [CelebrationParticle] = []
    
    enum CelebrationType {
        case discovery
        case milestone
        case achievement
        case levelUp
        case streak
        
        var primaryColor: Color {
            switch self {
            case .discovery: return Color(red: 0.95, green: 0.77, blue: 0.06)
            case .milestone: return Color(red: 0.91, green: 0.12, blue: 0.39)
            case .achievement: return Color(red: 0.58, green: 0.42, blue: 0.94)
            case .levelUp: return Color(red: 0.26, green: 0.95, blue: 0.62)
            case .streak: return Color(red: 0.95, green: 0.42, blue: 0.26)
            }
        }
        
        var message: String {
            switch self {
            case .discovery: return "Mind Expanded!"
            case .milestone: return "Territory Conquered!"
            case .achievement: return "Achievement Unlocked!"
            case .levelUp: return "Level Up!"
            case .streak: return "Streak Extended!"
            }
        }
        
        var icon: String {
            switch self {
            case .discovery: return "brain"
            case .milestone: return "flag.fill"
            case .achievement: return "trophy.fill"
            case .levelUp: return "arrow.up.circle.fill"
            case .streak: return "flame.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Particle explosion
            ForEach(particles) { particle in
                Image(systemName: particle.symbol)
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
            }
            
            // Central celebration message
            if isAnimating {
                VStack(spacing: 20) {
                    // Icon burst
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        type.primaryColor.opacity(0.6),
                                        type.primaryColor.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: isAnimating ? 150 : 50
                                )
                            )
                            .frame(width: 300, height: 300)
                            .blur(radius: 20)
                            .scaleEffect(isAnimating ? 1.5 : 0.5)
                        
                        // Main icon
                        Image(systemName: type.icon)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        type.primaryColor,
                                        type.primaryColor.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isAnimating ? 1.2 : 0)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    }
                    
                    // Message
                    Text(type.message)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    type.primaryColor,
                                    type.primaryColor.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0)
                        .shadow(color: type.primaryColor.opacity(0.3), radius: 10)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            triggerCelebration()
        }
    }
    
    private func triggerCelebration() {
        // Generate particles
        generateParticles()
        
        // Trigger haptic feedback
        HapticManager.shared.notification(type: .success)
        
        // Animate in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            isAnimating = true
        }
        
        // Animate particles
        for (index, _) in particles.enumerated() {
            withAnimation(.easeOut(duration: Double.random(in: 1.5...2.5)).delay(Double(index) * 0.02)) {
                particles[index].position = CGPoint(
                    x: particles[index].targetPosition.x,
                    y: particles[index].targetPosition.y
                )
                particles[index].opacity = 0
                particles[index].scale = 0.1
                particles[index].rotation = Double.random(in: 180...720)
            }
        }
        
        // Fade out after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = false
            }
        }
    }
    
    private func generateParticles() {
        let symbols = ["star.fill", "sparkle", "circle.fill", "diamond.fill", "heart.fill"]
        let colors = [
            type.primaryColor,
            type.primaryColor.opacity(0.8),
            Color(red: 0.95, green: 0.77, blue: 0.06),
            Color.white
        ]
        
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2
        
        for _ in 0..<30 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 150...300)
            
            let particle = CelebrationParticle(
                id: UUID(),
                symbol: symbols.randomElement()!,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 12...24),
                position: CGPoint(x: centerX, y: centerY),
                targetPosition: CGPoint(
                    x: centerX + cos(angle) * distance,
                    y: centerY + sin(angle) * distance
                ),
                opacity: 1.0,
                scale: 1.0,
                rotation: 0
            )
            particles.append(particle)
        }
    }
}

// MARK: - Micro Delight Button
struct MicroDelightButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    
    var body: some View {
        Button(action: {
            triggerDelight()
            action()
        }) {
            ZStack {
                // Ripple effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.95, green: 0.77, blue: 0.06).opacity(rippleOpacity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .scaleEffect(rippleScale)
                    .frame(width: 200, height: 200)
                
                // Button content
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .rotationEffect(.degrees(isPressed ? 360 : 0))
                    
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.77, blue: 0.06),
                            Color(red: 0.95, green: 0.42, blue: 0.26)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.3),
                    radius: isPressed ? 5 : 10,
                    y: isPressed ? 2 : 5
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func triggerDelight() {
        // Haptic feedback
        HapticManager.shared.impact(style: .light)
        
        // Press animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        
        // Ripple effect
        withAnimation(.easeOut(duration: 0.6)) {
            rippleScale = 2.0
            rippleOpacity = 0.3
        }
        
        // Reset animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            rippleScale = 0
            rippleOpacity = 0
        }
    }
}

// MARK: - Emotional Progress Ring
struct EmotionalProgressRing: View {
    let progress: Double
    let label: String
    let color: Color
    @State private var animatedProgress: Double = 0
    @State private var glowAnimation = false
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 12)
                .frame(width: 120, height: 120)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            color,
                            color.opacity(0.8),
                            color,
                            color.opacity(0.6),
                            color
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(glowAnimation ? 0.6 : 0.3), radius: glowAnimation ? 15 : 8)
            
            // Center content
            VStack(spacing: 4) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.2)) {
                animatedProgress = progress
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowAnimation = true
            }
        }
    }
}

// MARK: - Discovery Pulse Animation
struct DiscoveryPulse: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 1.0
    let color: Color
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                        value: pulseScale
                    )
            }
        }
        .onAppear {
            pulseScale = 3.0
            pulseOpacity = 0
        }
    }
}

// MARK: - Emotional Transition
struct EmotionalTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1.0 : 0.8)
            .opacity(isActive ? 1.0 : 0)
            .blur(radius: isActive ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - Floating Achievement Badge
struct FloatingAchievementBadge: View {
    let achievement: Achievement
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    
    struct Achievement {
        let title: String
        let description: String
        let icon: String
        let color: Color
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(achievement.color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(achievement.color, lineWidth: 2)
                )
        )
        .shadow(color: achievement.color.opacity(0.5), radius: 10)
        .offset(y: offset)
        .opacity(opacity)
        .scaleEffect(scale)
        .onAppear {
            showAchievement()
        }
    }
    
    private func showAchievement() {
        // Play sound
        HapticManager.shared.notification(type: .success)
        
        // Animate in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            offset = 0
            opacity = 1
            scale = 1
        }
        
        // Float animation
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
            offset = -10
        }
        
        // Fade out after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 0
                scale = 0.8
            }
        }
    }
}

// MARK: - Emotional State Indicator
struct EmotionalStateIndicator: View {
    let state: EmotionalState
    @State private var isAnimating = false
    
    enum EmotionalState {
        case curious
        case enlightened
        case challenged
        case triumphant
        case reflective
        
        var color: Color {
            switch self {
            case .curious: return Color(red: 0.26, green: 0.62, blue: 0.95)
            case .enlightened: return Color(red: 0.95, green: 0.77, blue: 0.06)
            case .challenged: return Color(red: 0.95, green: 0.42, blue: 0.26)
            case .triumphant: return Color(red: 0.26, green: 0.95, blue: 0.62)
            case .reflective: return Color(red: 0.58, green: 0.42, blue: 0.94)
            }
        }
        
        var icon: String {
            switch self {
            case .curious: return "questionmark.circle.fill"
            case .enlightened: return "lightbulb.fill"
            case .challenged: return "flame.fill"
            case .triumphant: return "crown.fill"
            case .reflective: return "moon.stars.fill"
            }
        }
        
        var label: String {
            switch self {
            case .curious: return "Curious"
            case .enlightened: return "Enlightened"
            case .challenged: return "Challenged"
            case .triumphant: return "Triumphant"
            case .reflective: return "Reflective"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: state.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(state.color)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            
            Text(state.label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(state.color.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(state.color.opacity(0.5), lineWidth: 1)
                )
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Supporting Models
struct CelebrationParticle: Identifiable {
    let id: UUID
    let symbol: String
    let color: Color
    let size: CGFloat
    var position: CGPoint
    let targetPosition: CGPoint
    var opacity: Double
    var scale: CGFloat
    var rotation: Double
}

// MARK: - View Extensions
extension View {
    func emotionalTransition(isActive: Bool) -> some View {
        self.modifier(EmotionalTransition(isActive: isActive))
    }
}