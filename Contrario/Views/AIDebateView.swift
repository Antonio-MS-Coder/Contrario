import SwiftUI

// Mock AI Debate Service for now
class AIDebateService: ObservableObject {
    @Published var isLoading = false
    @Published var currentDebate: String = ""
    @Published var messages: [DebateMessage] = []
    
    func startDebate(on fact: ContraryFact) {
        // Mock implementation
    }
    
    func submitArgument(_ argument: String) {
        // Mock implementation
    }
}

struct DebateMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct AIDebateView: View {
    @ObservedObject var aiService: AIDebateService
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var selectedTopic = "Current fact"
    @State private var isTyping = false
    @State private var debateStarted = false
    
    let debateTopics = [
        "Current fact",
        "Technology's impact on society",
        "The future of work",
        "Democracy vs efficiency",
        "Individual vs collective good"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean background
                Color(red: 0.16, green: 0.11, blue: 0.29)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    DebateHeader(
                        selectedTopic: $selectedTopic,
                        topics: debateTopics,
                        onStartDebate: startDebate
                    )
                    
                    // Messages area
                    if debateStarted {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 12) {
                                    ForEach(aiService.messages, id: \.id) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                    
                                    if isTyping {
                                        TypingIndicator()
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: aiService.messages.count) { _ in
                                if let lastMessage = aiService.messages.last {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    } else {
                        // Welcome state
                        DebateWelcome(onQuickStart: {
                            selectedTopic = debateTopics.randomElement() ?? debateTopics[0]
                            startDebate()
                        })
                    }
                    
                    // Input area
                    if debateStarted {
                        MessageInputView(
                            messageText: $messageText,
                            isTyping: isTyping,
                            onSend: sendMessage
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetDebate()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .disabled(!debateStarted)
                }
            }
        }
    }
    
    private func startDebate() {
        debateStarted = true
        // For now, just use a mock fact
        let mockFact = ContraryFact(text: selectedTopic, category: "general", source: "", contraryInsight: "")
        aiService.startDebate(on: mockFact)
        
        // Add initial AI message
        let welcomeMessage = DebateMessage(
            text: "I'm ready to challenge your thinking on '\(selectedTopic)'. What's your initial position?",
            isUser: false,
            timestamp: Date()
        )
        aiService.messages.append(welcomeMessage)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = DebateMessage(
            text: messageText,
            isUser: true,
            timestamp: Date()
        )
        aiService.messages.append(userMessage)
        aiService.submitArgument(messageText)
        messageText = ""
        
        // Show typing indicator
        isTyping = true
        
        // Simulate AI response (replace with actual AI service)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isTyping = false
            
            let responses = [
                "That's an interesting perspective. However, have you considered that...",
                "I see your point, but what if we flip that assumption?",
                "Let me challenge that with a contrarian view...",
                "Interesting. But doesn't that ignore the possibility that...",
                "I respectfully disagree. Here's why your premise might be flawed..."
            ]
            
            let aiResponse = DebateMessage(
                text: responses.randomElement() ?? responses[0],
                isUser: false,
                timestamp: Date()
            )
            aiService.messages.append(aiResponse)
        }
    }
    
    private func resetDebate() {
        aiService.messages.removeAll()
        debateStarted = false
        messageText = ""
        isTyping = false
    }
}

// MARK: - Supporting Views

struct DebateHeader: View {
    @Binding var selectedTopic: String
    let topics: [String]
    let onStartDebate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("AI Debate Partner")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Engage in intellectual sparring with AI")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            // Topic selector
            Menu {
                ForEach(topics, id: \.self) { topic in
                    Button(topic) {
                        selectedTopic = topic
                    }
                }
            } label: {
                HStack {
                    Text("Topic: \(selectedTopic)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            Button(action: onStartDebate) {
                Text("Start Debate")
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
        .padding()
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
        )
    }
}

struct DebateWelcome: View {
    let onQuickStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.06))
                
                Text("Ready to Challenge Your Thinking?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("The AI will take contrarian positions to help you think more deeply about complex topics.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: onQuickStart) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                    Text("Quick Start")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MessageBubble: View {
    let message: DebateMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(message.isUser ? .white : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isUser ? 
                                  Color(red: 0.95, green: 0.77, blue: 0.06) : 
                                  Color.white.opacity(0.15))
                    )
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 40)
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationOffset == CGFloat(index) ? 1.2 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.15))
            )
            
            Spacer(minLength: 40)
        }
        .onAppear {
            animationOffset = 2
        }
    }
}

struct MessageInputView: View {
    @Binding var messageText: String
    let isTyping: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 12) {
                TextField("Type your argument...", text: $messageText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .lineLimit(1...4)
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(
                            !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                            Color(red: 0.95, green: 0.77, blue: 0.06) : 
                            Color.white.opacity(0.3)
                        )
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTyping)
            }
            .padding()
        }
        .background(Color(red: 0.16, green: 0.11, blue: 0.29))
    }
}