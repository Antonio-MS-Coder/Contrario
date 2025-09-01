import SwiftUI

// MARK: - Reusable UI Components for Complex Features

struct LoadingStateView: View {
    let message: String
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 32))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ErrorStateView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("Retry")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.95, green: 0.77, blue: 0.06))
                        )
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ProgressiveDisclosureCard: View {
    let title: String
    let subtitle: String
    let content: AnyView
    let isUnlocked: Bool
    let unlockRequirement: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                if isUnlocked {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isUnlocked ? .white : .white.opacity(0.6))
                        
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(isUnlocked ? .white.opacity(0.7) : .white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    if isUnlocked {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(unlockRequirement)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(16)
            }
            .disabled(!isUnlocked)
            
            // Expandable content
            if isExpanded && isUnlocked {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isUnlocked ? Color.white.opacity(0.1) : Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct FeatureGate: View {
    let title: String
    let description: String
    let requirement: String
    let isUnlocked: Bool
    let onUnlock: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isUnlocked ? "checkmark.shield.fill" : "lock.shield.fill")
                .font(.system(size: 32))
                .foregroundColor(isUnlocked ? .green : .orange)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            if !isUnlocked {
                Text("Requirement: \(requirement)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.5), lineWidth: 1)
                            )
                    )
            } else {
                Button("Continue", action: onUnlock)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(red: 0.95, green: 0.77, blue: 0.06))
                    )
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct AsyncContentView<Content: View, LoadingView: View, ErrorView: View>: View {
    let content: () -> Content
    let loadingView: () -> LoadingView
    let errorView: (Error) -> ErrorView
    let loadAction: () async throws -> Void
    
    @State private var loadingState: LoadingState = .idle
    
    enum LoadingState {
        case idle
        case loading
        case loaded
        case error(Error)
    }
    
    var body: some View {
        Group {
            switch loadingState {
            case .idle, .loading:
                loadingView()
            case .loaded:
                content()
            case .error(let error):
                errorView(error)
            }
        }
        .task {
            await performLoad()
        }
    }
    
    private func performLoad() async {
        loadingState = .loading
        
        do {
            try await loadAction()
            loadingState = .loaded
        } catch {
            loadingState = .error(error)
        }
    }
}

struct SmartRefreshable<Content: View>: View {
    let content: Content
    let refreshAction: () async -> Void
    @State private var isRefreshing = false
    
    var body: some View {
        content
            .refreshable {
                isRefreshing = true
                await refreshAction()
                isRefreshing = false
            }
            .overlay(
                Group {
                    if isRefreshing {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.95, green: 0.77, blue: 0.06)))
                                .scaleEffect(0.8)
                            
                            Text("Refreshing insights...")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                        )
                        .transition(.opacity)
                    }
                },
                alignment: .top
            )
    }
}

struct ContextualTooltip: View {
    let text: String
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}


struct GradualReveal<Content: View>: View {
    let content: Content
    let delay: Double
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    opacity = 1
                    scale = 1
                }
            }
    }
}

struct PerformantList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let content: (Data.Element) -> Content
    let threshold: Int = 20
    
    var body: some View {
        if data.count > threshold {
            LazyVStack(spacing: 8) {
                ForEach(data, id: \.id) { item in
                    content(item)
                }
            }
        } else {
            VStack(spacing: 8) {
                ForEach(data, id: \.id) { item in
                    content(item)
                }
            }
        }
    }
}

// MARK: - Transition Types

enum TransitionType {
    case scale
    case slide
    case fade
    case flip
}

// MARK: - Animation Modifiers

extension View {
    func microDelight(trigger: some Hashable) -> some View {
        self.modifier(MicroDelightModifier(trigger: trigger))
    }
    
    func contextualPulse(isActive: Bool, color: Color = Color(red: 0.95, green: 0.77, blue: 0.06)) -> some View {
        self.modifier(ContextualPulseModifier(isActive: isActive, color: color))
    }
    
    func smartTransition<T: Hashable>(trigger: T, type: TransitionType = .scale) -> some View {
        self.modifier(SmartTransitionModifier(trigger: trigger, type: type))
    }
}

struct MicroDelightModifier: ViewModifier {
    let trigger: AnyHashable
    @State private var scale: CGFloat = 1
    
    init<T: Hashable>(trigger: T) {
        self.trigger = AnyHashable(trigger)
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.05
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                    scale = 1
                }
            }
    }
}

struct ContextualPulseModifier: ViewModifier {
    let isActive: Bool
    let color: Color
    @State private var opacity: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
                    .opacity(isActive ? opacity : 0)
                    .animation(
                        isActive ? .easeInOut(duration: 1).repeatForever(autoreverses: true) : .easeOut(duration: 0.3),
                        value: isActive
                    )
            )
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        opacity = 0.8
                    }
                }
            }
    }
}

struct SmartTransitionModifier: ViewModifier {
    let trigger: AnyHashable
    let type: TransitionType
    @State private var isVisible = true
    
    init<T: Hashable>(trigger: T, type: TransitionType) {
        self.trigger = AnyHashable(trigger)
        self.type = type
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(type == .scale ? (isVisible ? 1 : 0.8) : 1)
            .offset(x: type == .slide ? (isVisible ? 0 : -50) : 0)
            .rotation3DEffect(
                .degrees(type == .flip ? (isVisible ? 0 : 90) : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onChange(of: trigger) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }
                withAnimation(.easeInOut(duration: 0.3).delay(0.15)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Performance Optimizations

struct LazyContent<Content: View>: View {
    let content: () -> Content
    @State private var hasAppeared = false
    
    var body: some View {
        Group {
            if hasAppeared {
                content()
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
            }
        }
        .onAppear {
            hasAppeared = true
        }
    }
}

struct MemoryOptimizedImage: View {
    let systemName: String
    let size: CGFloat
    let color: Color
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size))
            .foregroundColor(color)
            .imageScale(.medium) // Optimize for memory
    }
}
