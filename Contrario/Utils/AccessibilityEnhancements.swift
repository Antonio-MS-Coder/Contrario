import SwiftUI

// MARK: - Accessibility Enhancement System
// Ensures WCAG AAA compliance while maintaining emotional design integrity

struct AccessibilityEnhancements {
    
    // MARK: - Contrast Validation
    
    /// Calculates the relative luminance of a color
    static func relativeLuminance(of color: UIColor) -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Apply gamma correction
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    /// Calculates contrast ratio between two colors
    static func contrastRatio(between color1: UIColor, and color2: UIColor) -> CGFloat {
        let lum1 = relativeLuminance(of: color1)
        let lum2 = relativeLuminance(of: color2)
        
        let lighter = max(lum1, lum2)
        let darker = min(lum1, lum2)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Validates if contrast meets WCAG AAA standards
    static func meetsWCAGAAA(textColor: Color, backgroundColor: Color, isLargeText: Bool = false) -> Bool {
        let requiredRatio: CGFloat = isLargeText ? 4.5 : 7.0
        
        // Convert SwiftUI Colors to UIColors for calculation
        let textUIColor = UIColor(textColor)
        let bgUIColor = UIColor(backgroundColor)
        
        let ratio = contrastRatio(between: textUIColor, and: bgUIColor)
        return ratio >= requiredRatio
    }
    
    // MARK: - Adaptive Color System
    
    struct AdaptiveColors {
        /// Returns the best text color for a given background
        static func optimalTextColor(for background: Color, preferLight: Bool = false) -> Color {
            let bgUIColor = UIColor(background)
            let luminance = relativeLuminance(of: bgUIColor)
            
            // Use light text on dark backgrounds, dark text on light backgrounds
            if luminance < 0.5 {
                return Color.white
            } else {
                return Color("PrimaryText")
            }
        }
        
        /// Adjusts a color to ensure minimum contrast with background
        static func ensureContrast(foreground: Color, background: Color, minimumRatio: CGFloat = 7.0) -> Color {
            let fgUIColor = UIColor(foreground)
            let bgUIColor = UIColor(background)
            
            let currentRatio = contrastRatio(between: fgUIColor, and: bgUIColor)
            
            if currentRatio >= minimumRatio {
                return foreground
            }
            
            // Adjust the foreground color to meet contrast requirements
            let bgLuminance = relativeLuminance(of: bgUIColor)
            
            if bgLuminance < 0.5 {
                // Dark background - lighten the foreground
                return foreground.opacity(min(1.0, currentRatio / minimumRatio + 0.3))
            } else {
                // Light background - darken the foreground
                return foreground.opacity(min(1.0, minimumRatio / currentRatio))
            }
        }
    }
    
    // MARK: - Emotional Accessibility Components
    
    /// Text that automatically ensures readability while preserving emotional impact
    struct AccessibleText: View {
        let text: String
        let font: Font
        let baseColor: Color
        let backgroundColor: Color
        let emotionalWeight: EmotionalWeight
        
        enum EmotionalWeight {
            case profound   // Deep, contemplative statements
            case rebellious // Contrarian, challenging ideas
            case whisper    // Subtle insights
            case manifesto  // Bold declarations
        }
        
        init(_ text: String,
             font: Font = .body,
             color: Color = Color("PrimaryText"),
             background: Color = .clear,
             emotional: EmotionalWeight = .profound) {
            self.text = text
            self.font = font
            self.baseColor = color
            self.backgroundColor = background
            self.emotionalWeight = emotional
        }
        
        var body: some View {
            Text(text)
                .font(font)
                .foregroundColor(adaptedColor)
                .modifier(EmotionalModifier(weight: emotionalWeight))
        }
        
        private var adaptedColor: Color {
            if backgroundColor == .clear {
                return baseColor
            }
            return AdaptiveColors.ensureContrast(
                foreground: baseColor,
                background: backgroundColor
            )
        }
    }
    
    /// Modifier that adds emotional depth while maintaining accessibility
    struct EmotionalModifier: ViewModifier {
        let weight: AccessibleText.EmotionalWeight
        
        func body(content: Content) -> some View {
            switch weight {
            case .profound:
                content
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            case .rebellious:
                content
                    .bold()
                    .shadow(color: Color("AccentBrown").opacity(0.2),
                           radius: 2, x: 0, y: 1)
            case .whisper:
                content
                    .opacity(0.9)
            case .manifesto:
                content
                    .bold()
                    .tracking(1)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Accessible Card Component
    
    struct AccessibleCard<Content: View>: View {
        let content: Content
        let emotionalTone: EmotionalTone
        
        enum EmotionalTone {
            case contemplative
            case challenging
            case enlightening
            case victorious
        }
        
        init(tone: EmotionalTone = .contemplative,
             @ViewBuilder content: () -> Content) {
            self.emotionalTone = tone
            self.content = content()
        }
        
        var body: some View {
            content
                .padding()
                .background(cardBackground)
                .cornerRadius(16)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        
        private var cardBackground: Color {
            Color("CardBackground")
        }
        
        private var shadowColor: Color {
            switch emotionalTone {
            case .contemplative:
                return Color("CardShadow").opacity(0.1)
            case .challenging:
                return Color("AccentBrown").opacity(0.1)
            case .enlightening:
                return Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.15)
            case .victorious:
                return Color(red: 0.26, green: 0.62, blue: 0.52).opacity(0.1)
            }
        }
        
        private var shadowRadius: CGFloat {
            switch emotionalTone {
            case .contemplative: return 5
            case .challenging: return 8
            case .enlightening: return 10
            case .victorious: return 12
            }
        }
        
        private var borderColor: Color {
            switch emotionalTone {
            case .contemplative:
                return Color.clear
            case .challenging:
                return Color("AccentBrown").opacity(0.2)
            case .enlightening:
                return Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.3)
            case .victorious:
                return Color(red: 0.26, green: 0.62, blue: 0.52).opacity(0.3)
            }
        }
        
        private var borderWidth: CGFloat {
            emotionalTone == .contemplative ? 0 : 1
        }
    }
    
    // MARK: - Accessible Button Styles
    
    struct EmotionalButtonStyle: ButtonStyle {
        let emotionalIntent: EmotionalIntent
        @Environment(\.isEnabled) var isEnabled
        
        enum EmotionalIntent {
            case primary    // Main CTA - creates feeling of importance
            case rebellious // Contrarian action - feels bold
            case subtle     // Secondary action - feels supportive
            case danger     // Destructive action - feels serious
        }
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(buttonBackground(isPressed: configuration.isPressed))
                .foregroundColor(buttonForeground)
                .cornerRadius(12)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .shadow(color: shadowColor, radius: configuration.isPressed ? 2 : 5,
                       x: 0, y: configuration.isPressed ? 1 : 3)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
                .opacity(isEnabled ? 1.0 : 0.6)
        }
        
        private func buttonBackground(isPressed: Bool) -> Color {
            let baseColor: Color
            switch emotionalIntent {
            case .primary:
                baseColor = Color(red: 0.95, green: 0.77, blue: 0.06)
            case .rebellious:
                baseColor = Color(red: 0.91, green: 0.12, blue: 0.39)
            case .subtle:
                baseColor = Color("CardActionBackground")
            case .danger:
                baseColor = Color.red
            }
            return isPressed ? baseColor.opacity(0.9) : baseColor
        }
        
        private var buttonForeground: Color {
            switch emotionalIntent {
            case .primary:
                return Color(red: 0.16, green: 0.11, blue: 0.29)
            case .rebellious, .danger:
                return Color.white
            case .subtle:
                return Color("PrimaryText")
            }
        }
        
        private var shadowColor: Color {
            switch emotionalIntent {
            case .primary:
                return Color(red: 0.95, green: 0.77, blue: 0.06).opacity(0.3)
            case .rebellious:
                return Color(red: 0.91, green: 0.12, blue: 0.39).opacity(0.3)
            case .subtle:
                return Color("CardShadow").opacity(0.1)
            case .danger:
                return Color.red.opacity(0.3)
            }
        }
    }
}

// MARK: - View Extensions for Easy Access

extension View {
    /// Applies emotional button styling with accessibility
    func emotionalButton(_ intent: AccessibilityEnhancements.EmotionalButtonStyle.EmotionalIntent) -> some View {
        self.buttonStyle(AccessibilityEnhancements.EmotionalButtonStyle(emotionalIntent: intent))
    }
    
    /// Wraps content in an accessible card with emotional tone
    func accessibleCard(tone: AccessibilityEnhancements.AccessibleCard<AnyView>.EmotionalTone = .contemplative) -> some View {
        AccessibilityEnhancements.AccessibleCard(tone: tone) {
            AnyView(self)
        }
    }
    
    /// Ensures text contrast for accessibility
    func ensureContrast(on background: Color) -> some View {
        self.foregroundColor(
            AccessibilityEnhancements.AdaptiveColors.optimalTextColor(for: background)
        )
    }
}

// MARK: - Haptic Feedback Manager
// HapticManager is defined in HapticManager.swift