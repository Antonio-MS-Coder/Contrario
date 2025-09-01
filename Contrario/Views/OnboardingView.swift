import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep = 0
    @State private var userName = ""
    
    var body: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.11, blue: 0.29),
                    Color(red: 0.31, green: 0.20, blue: 0.48)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index <= currentStep ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentStep)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Content
                Group {
                    switch currentStep {
                    case 0:
                        WelcomeStep()
                    case 1:
                        PurposeStep()
                    case 2:
                        GetStartedStep(userName: $userName)
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    Button(action: {
                        if currentStep < 2 {
                            currentStep += 1
                        } else {
                            // Save user name if provided
                            if !userName.isEmpty {
                                UserDefaults.standard.set(userName, forKey: "userName")
                            }
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text(currentStep == 2 ? "Start Exploring" : "Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.16, green: 0.11, blue: 0.29))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - Onboarding Steps

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(.bottom, 10)
            
            Text("Welcome to Contrario")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Challenge conventional wisdom with contrarian insights that reshape your thinking")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal)
    }
}

struct PurposeStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Expand Your Mind")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 25) {
                FeatureRow(
                    icon: "lightbulb.fill",
                    title: "Discover Contrarian Facts",
                    description: "Uncover perspectives that challenge the mainstream"
                )
                
                FeatureRow(
                    icon: "newspaper.fill",
                    title: "Read Hacker News",
                    description: "Stay updated with tech news and discussions"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Journey",
                    description: "Monitor your intellectual growth and discoveries"
                )
            }
        }
        .padding(.horizontal)
    }
}

struct GetStartedStep: View {
    @Binding var userName: String
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Personalize Your Experience")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("What should we call you?")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
            
            TextField("Your name (optional)", text: $userName)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .multilineTextAlignment(.center)
            
            Text("Ready to think differently?")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 20)
        }
        .padding(.horizontal)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}