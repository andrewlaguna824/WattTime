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
    let rateInfo: (rate: RateType, period: RatePeriod, nextChange: Date)
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
    let rateInfo: (rate: RateType, period: RatePeriod, nextChange: Date)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rateInfo.rate.name)
                .font(.headline)
                .foregroundColor(Color(rateInfo.rate.color))
            
            Text(rateInfo.rate.formattedRate())
                .font(.title2)
                .bold()
            
            Text("Next: \(rateInfo.period.formattedTimeRange)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DetailedRateView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextChange: Date)
    
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
                
                Text("Next Change")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(EnergyData.formattedNextRateChange(from: rateInfo.nextChange))
                    .font(.subheadline)
            }
        }
        .padding()
    }
} 