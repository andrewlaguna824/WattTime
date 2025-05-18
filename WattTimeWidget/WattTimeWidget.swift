import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let nextChange = EnergyData.nextRateChange(from: currentDate)
        
        // Create entries for current period and next period
        let entries = [
            SimpleEntry(date: currentDate),
            SimpleEntry(date: nextChange)
        ]
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WattTimeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let rateInfo = EnergyData.currentRateInfo(for: entry.date)
        
        switch family {
        case .systemSmall:
            RateInfoView(rateInfo: rateInfo, style: .compact)
        case .systemMedium:
            RateInfoView(rateInfo: rateInfo, style: .detailed)
        default:
            RateInfoView(rateInfo: rateInfo, style: .compact)
        }
    }
}

struct WattTimeWidget: Widget {
    let kind: String = "WattTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WattTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WattTime Widget")
        .description("Display current energy rates and next rate change.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WattTimeWidget()
} timeline: {
    SimpleEntry(date: .now)
}

#Preview(as: .systemMedium) {
    WattTimeWidget()
} timeline: {
    SimpleEntry(date: .now)
} 