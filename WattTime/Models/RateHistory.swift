import Foundation

struct RateHistory: Identifiable {
    let id = UUID()
    let date: Date
    let rateType: RateType
    let duration: TimeInterval
    
    static func generateHistory(for days: Int = 7) -> [RateHistory] {
        let calendar = Calendar.current
        let now = Date()
        var history: [RateHistory] = []
        
        for day in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            let isWeekend = calendar.isDateInWeekend(date)
            let month = calendar.component(.month, from: date)
            let isWinter = (month >= 10 || month <= 5)
            
            let rates: [RatePeriod]
            if isWinter {
                rates = isWeekend ? EnergyData.winterWeekendRates : EnergyData.winterWeekdayRates
            } else {
                rates = isWeekend ? EnergyData.summerWeekendRates : EnergyData.summerWeekdayRates
            }
            
            for period in rates {
                let startDate = calendar.date(bySettingHour: period.startHour, minute: 0, second: 0, of: date)!
                let endDate = calendar.date(bySettingHour: period.endHour, minute: 0, second: 0, of: date)!
                
                history.append(RateHistory(
                    date: startDate,
                    rateType: period.rateType,
                    duration: endDate.timeIntervalSince(startDate)
                ))
            }
        }
        
        return history.sorted { $0.date > $1.date }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let hours = Int(duration / 3600)
        return "\(hours) hour\(hours == 1 ? "" : "s")"
    }
} 
