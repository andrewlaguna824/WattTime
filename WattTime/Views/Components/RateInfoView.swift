import SwiftUI

struct RateInfoView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    let style: RateInfoStyle
    
    enum RateInfoStyle {
        case compact
        case detailed
        case card
    }
    
    var body: some View {
        switch style {
        case .compact:
            CompactRateView(rateInfo: rateInfo)
        case .detailed:
            DetailedRateView(rateInfo: rateInfo)
        case .card:
            RateCardView(rateInfo: rateInfo)
        }
    }
}

struct CompactRateView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    
    var body: some View {
        VStack(spacing: 8) {
            Text(rateInfo.rate.name)
                .font(.headline)
                .foregroundColor(Color(rateInfo.rate.color))
            
            Text(rateInfo.rate.formattedRate())
                .font(.title2)
                .bold()
            
            Text(rateInfo.period.formattedTimeRange)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Next: \(rateInfo.nextPeriod.rateType.name)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(rateInfo.nextPeriod.formattedTimeRange)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DetailedRateView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(rateInfo.rate.name)
                    .font(.headline)
                    .foregroundColor(Color(rateInfo.rate.color))
                
                Text(rateInfo.rate.formattedRate())
                    .font(.title)
                    .bold()
                
                Text(rateInfo.period.formattedTimeRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("Next Period")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(rateInfo.nextPeriod.rateType.name)
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(rateInfo.nextPeriod.rateType.color))
                
                Text(rateInfo.nextPeriod.formattedTimeRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if rateInfo.rate.isPeakRate {
                    Text("Consider delaying usage")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text("Good time to use power")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
    }
}

struct RateCardView: View {
    let rateInfo: (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod)
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(rateInfo.rate.name)
                        .font(.headline)
                        .foregroundColor(Color(rateInfo.rate.color))
                    Text(rateInfo.rate.formattedRate())
                        .font(.title)
                        .bold()
                }
                Spacer()
                Image(systemName: rateInfo.rate.isPeakRate ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(rateInfo.rate.isPeakRate ? .orange : .green)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text(rateInfo.period.formattedTimeRange)
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.secondary)
                    Text("Next: \(rateInfo.nextPeriod.rateType.name)")
                        .font(.subheadline)
                        .foregroundColor(Color(rateInfo.nextPeriod.rateType.color))
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text(rateInfo.nextPeriod.formattedTimeRange)
                        .font(.subheadline)
                }
            }
            
            if rateInfo.rate.isPeakRate {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)
                    Text("Consider delaying non-essential power usage")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

#Preview {
    VStack(spacing: 20) {
        RateInfoView(rateInfo: EnergyData.currentRateInfo(), style: .compact)
        RateInfoView(rateInfo: EnergyData.currentRateInfo(), style: .detailed)
        RateInfoView(rateInfo: EnergyData.currentRateInfo(), style: .card)
    }
    .padding()
} 