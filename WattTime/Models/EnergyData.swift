import Foundation

enum RateType: String, Codable {
    case superOffPeak = "Super Off-Peak"
    case offPeak = "Off-Peak"
    case midPeak = "Mid-Peak"
    case onPeak = "On-Peak"
    
    var rate: Double {
        switch self {
        case .superOffPeak: return 0.35
        case .offPeak: return 0.36
        case .midPeak: return 0.48
        case .onPeak: return 0.59
        }
    }
    
    var color: String {
        switch self {
        case .superOffPeak: return "green"
        case .offPeak: return "blue"
        case .midPeak: return "orange"
        case .onPeak: return "red"
        }
    }
    
    var formattedRate: String {
        String(format: "%.2f¢", rate * 100)
    }
    
    var isPeakRate: Bool {
        self == .midPeak || self == .onPeak
    }
}

struct RatePeriod: Codable {
    let startHour: Int
    let endHour: Int
    let rateType: RateType
    
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour >= startHour && hour < endHour
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        
        let calendar = Calendar.current
        let now = Date()
        
        guard let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: now),
              let endDate = calendar.date(bySettingHour: endHour, minute: 0, second: 0, of: now) else {
            return "Invalid time range"
        }
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct EnergyData: Codable {
    let timestamp: Date
    let currentUsage: Double
    let unit: String
    
    // Winter rates (October to May)
    static let winterWeekdayRates: [RatePeriod] = [
        RatePeriod(startHour: 0, endHour: 8, rateType: .offPeak),
        RatePeriod(startHour: 8, endHour: 16, rateType: .superOffPeak),
        RatePeriod(startHour: 16, endHour: 21, rateType: .midPeak),
        RatePeriod(startHour: 21, endHour: 24, rateType: .offPeak)
    ]
    
    static let winterWeekendRates: [RatePeriod] = [
        RatePeriod(startHour: 0, endHour: 8, rateType: .offPeak),
        RatePeriod(startHour: 8, endHour: 16, rateType: .superOffPeak),
        RatePeriod(startHour: 16, endHour: 21, rateType: .midPeak),
        RatePeriod(startHour: 21, endHour: 24, rateType: .offPeak)
    ]
    
    // Summer rates (June to September)
    static let summerWeekdayRates: [RatePeriod] = [
        RatePeriod(startHour: 0, endHour: 16, rateType: .offPeak),
        RatePeriod(startHour: 16, endHour: 21, rateType: .onPeak),
        RatePeriod(startHour: 21, endHour: 24, rateType: .offPeak)
    ]
    
    static let summerWeekendRates: [RatePeriod] = [
        RatePeriod(startHour: 0, endHour: 16, rateType: .offPeak),
        RatePeriod(startHour: 16, endHour: 21, rateType: .midPeak),
        RatePeriod(startHour: 21, endHour: 24, rateType: .offPeak)
    ]
    
    static func currentRate(for date: Date = Date()) -> RateType {
        let calendar = Calendar.current
        let isWeekend = calendar.isDateInWeekend(date)
        let month = calendar.component(.month, from: date)
        let isWinter = month >= 10 || month <= 5
        
        let rates: [RatePeriod]
        if isWinter {
            rates = isWeekend ? winterWeekendRates : winterWeekdayRates
        } else {
            rates = isWeekend ? summerWeekendRates : summerWeekdayRates
        }
        
        return rates.first { $0.contains(date) }?.rateType ?? .offPeak
    }
    
    static func nextRateChange(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: date)
        let isWeekend = calendar.isDateInWeekend(date)
        let month = calendar.component(.month, from: date)
        let isWinter = month >= 10 || month <= 5

        let rates: [RatePeriod]
        if isWinter {
            rates = isWeekend ? winterWeekendRates : winterWeekdayRates
        } else {
            rates = isWeekend ? summerWeekendRates : summerWeekdayRates
        }
        
        guard let nextPeriod = rates.first(where: { $0.startHour > currentHour }) else {
            // If no next period today, return start of first period tomorrow
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
            return calendar.date(bySettingHour: rates[0].startHour, minute: 0, second: 0, of: tomorrow)!
        }
        
        return calendar.date(bySettingHour: nextPeriod.startHour, minute: 0, second: 0, of: date)!
    }
    
    static func currentRateInfo(for date: Date = Date()) -> (rate: RateType, period: RatePeriod, nextChange: Date) {
        let calendar = Calendar.current
        let isWeekend = calendar.isDateInWeekend(date)
        let month = calendar.component(.month, from: date)
        let isWinter = month >= 10 || month <= 5
        
        let rates: [RatePeriod]
        if isWinter {
            rates = isWeekend ? winterWeekendRates : winterWeekdayRates
        } else {
            rates = isWeekend ? summerWeekendRates : summerWeekdayRates
        }
        
        let currentPeriod = rates.first { $0.contains(date) } ?? rates[0]
        let nextChange = nextRateChange(from: date)
        
        return (currentPeriod.rateType, currentPeriod, nextChange)
    }
    
    static func formattedNextRateChange(from date: Date = Date()) -> String {
        let nextChange = nextRateChange(from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: nextChange)
    }
    
    static let sample = EnergyData(
        timestamp: Date(),
        currentUsage: 42.5,
        unit: "kWh"
    )
} 
