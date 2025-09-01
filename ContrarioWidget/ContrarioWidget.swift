import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            fact: "The best startup ideas seem like bad ideas at first",
            insight: "If it were obviously good, someone would already be doing it",
            source: "Peter Thiel",
            category: "Business"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let fact = getRandomFact()
        let entry = SimpleEntry(
            date: Date(),
            fact: fact.text,
            insight: fact.insight,
            source: fact.source,
            category: fact.category
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Get a random fact
        let fact = getRandomFact()
        let currentDate = Date()
        
        // Create a single entry for the current day
        let entry = SimpleEntry(
            date: currentDate,
            fact: fact.text,
            insight: fact.insight,
            source: fact.source,
            category: fact.category
        )
        entries.append(entry)
        
        // Update the widget at midnight to get a new fact
        let tomorrow = Calendar.current.startOfDay(for: currentDate).addingTimeInterval(86400)
        let timeline = Timeline(entries: entries, policy: .after(tomorrow))
        completion(timeline)
    }
    
    func getRandomFact() -> (text: String, insight: String, source: String, category: String) {
        let facts = [
            (text: "Competition is for losers",
             insight: "Monopolies drive progress",
             source: "Zero to One",
             category: "Business"),
            (text: "The most contrarian thing is not to oppose the crowd but to think for yourself",
             insight: "True contrarianism isn't reflexive opposition",
             source: "Peter Thiel",
             category: "Philosophy"),
            (text: "The best time to start a company is during a recession",
             insight: "Less competition, cheaper talent",
             source: "Startup Wisdom",
             category: "Economics"),
            (text: "Perfectionism is a form of procrastination",
             insight: "The pursuit of perfect prevents good enough",
             source: "Productivity Paradox",
             category: "Philosophy"),
            (text: "The future is already here, it's just not evenly distributed",
             insight: "Look at edge cases to see what's coming",
             source: "William Gibson",
             category: "Future")
        ]
        
        return facts.randomElement() ?? facts[0]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let fact: String
    let insight: String
    let source: String
    let category: String
}

struct ContrarioWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.widgetBackground
            
            VStack(alignment: .leading, spacing: 8) {
                // Category header
                HStack {
                    Image(systemName: getCategoryIcon(entry.category))
                        .font(.system(size: 12))
                        .foregroundColor(Color.widgetAccentBrown)
                    
                    Text(entry.category.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.widgetAccentBrown)
                    
                    Spacer()
                }
                
                // Main fact
                Text(entry.fact)
                    .font(.system(size: family == .systemSmall ? 14 : 16, weight: .medium))
                    .foregroundColor(Color.widgetPrimaryText)
                    .lineLimit(family == .systemSmall ? 3 : 4)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Insight (if space allows)
                if family != .systemSmall && !entry.insight.isEmpty {
                    Text("💡 \(entry.insight)")
                        .font(.system(size: 12))
                        .italic()
                        .foregroundColor(Color.widgetSecondaryText)
                        .lineLimit(2)
                }
                
                // Source
                if !entry.source.isEmpty {
                    Text("— \(entry.source)")
                        .font(.system(size: 10))
                        .foregroundColor(Color.widgetSubtitleText)
                }
            }
            .padding()
        }
    }
    
    func getCategoryIcon(_ category: String) -> String {
        let icons: [String: String] = [
            "Business": "briefcase.fill",
            "Philosophy": "brain",
            "Economics": "chart.line.uptrend.xyaxis",
            "Technology": "cpu",
            "Future": "arrow.forward.circle.fill"
        ]
        return icons[category] ?? "lightbulb.fill"
    }
}

@main
struct ContrarioWidget: Widget {
    let kind: String = "ContrarioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ContrarioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Contrario")
        .description("Daily contrarian wisdom")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ContrarioWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContrarioWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            fact: "Competition is for losers",
            insight: "Monopolies drive progress by having resources to innovate",
            source: "Zero to One",
            category: "Business"
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}