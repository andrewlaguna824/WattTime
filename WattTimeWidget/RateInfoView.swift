import SwiftUI
import WidgetKit

// Remove the WattTime imports since we'll use the shared models directly
// @_exported import struct WattTime.RateType
// @_exported import struct WattTime.RatePeriod
// @_exported import struct WattTime.EnergyData

enum RateInfoStyle {
    case compact
    case detailed
}

struct RateInfoView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    let style: RateInfoStyle
    
    var body: some View {
        switch style {
        case .compact:
            CompactRateView(rateInfo: rateInfo)
        case .detailed:
            DetailedRateView(rateInfo: rateInfo)
        }
    }
}

struct CompactRateView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(rateInfo.rate.name)
                .font(.caption)
                .foregroundColor(Color(rateInfo.rate.color))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(rateInfo.rate.formattedRate())
                .font(.title3)
                .bold()
            
            Text(rateInfo.period.formattedTimeRange)
                .font(.caption2)
                .foregroundColor(.secondary)

            Spacer()
                .frame(height: 2)
            
            Text("Next: \(rateInfo.nextPeriod.rateType.name)")
                .font(.caption2)
                .foregroundColor(Color(rateInfo.nextPeriod.rateType.color))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(rateInfo.nextPeriod.rateType.formattedRate())
                .font(.caption2)
                .bold()

            Text(rateInfo.nextPeriod.formattedTimeRange)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
    }
}

struct DetailedRateView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(rateInfo.rate.name)
                    .font(.headline)
                    .foregroundColor(Color(rateInfo.rate.color))
                
                Text(rateInfo.rate.formattedRate())
                    .font(.title)
                    .bold()
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Current Period")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(rateInfo.period.formattedTimeRange)
                    .font(.subheadline)
                
                Text("Next Period")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(rateInfo.nextPeriod.rateType.name)
                    .font(.subheadline)
                    .foregroundColor(Color(rateInfo.nextPeriod.rateType.color))
                
                Text(rateInfo.nextPeriod.formattedTimeRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
} 
