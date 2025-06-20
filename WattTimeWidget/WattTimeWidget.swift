//
//  WattTimeWidget.swift
//  WattTimeWidget
//
//  Created by Andrew Palmer on 5/18/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), rateInfo: EnergyData.currentRateInfo())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), rateInfo: EnergyData.currentRateInfo())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, rateInfo: EnergyData.currentRateInfo())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
}

struct WattTimeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        RateInfoView(rateInfo: entry.rateInfo, style: .compact)
    }
}

struct WattTimeWidget: Widget {
    let kind: String = "WattTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WattTimeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WattTimeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("WattTime")
        .description("Shows current electricity rate information.")
    }
}

#Preview(as: .systemSmall) {
    WattTimeWidget()
} timeline: {
    SimpleEntry(date: .now, rateInfo: EnergyData.currentRateInfo())
    SimpleEntry(date: .now.addingTimeInterval(3600), rateInfo: EnergyData.currentRateInfo())
}
