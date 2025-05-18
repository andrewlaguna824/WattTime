import Foundation
import SwiftUI

struct RateType: Codable {
    let name: String
    let winterRate: Double
    let summerRate: Double
    
    static let superOffPeak = RateType(
        name: "Super Off-Peak",
        winterRate: 0.35,
        summerRate: 0.35
    )
    
    static let offPeak = RateType(
        name: "Off-Peak",
        winterRate: 0.39,
        summerRate: 0.36
    )
    
    static let midPeak = RateType(
        name: "Mid-Peak",
        winterRate: 0.52,
        summerRate: 0.48
    )
    
    static let onPeak = RateType(
        name: "On-Peak",
        winterRate: 0.59,
        summerRate: 0.59
    )
    
    func rate(for date: Date = Date()) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let isWinter = month >= 10 || month <= 5
        
        return isWinter ? winterRate : summerRate
    }
    
    var color: Color {
        switch name {
        case "Super Off-Peak": return .green
        case "Off-Peak": return .blue
        case "Mid-Peak": return .orange
        case "On-Peak": return .red
        default: return .gray
        }
    }
    
    func formattedRate(for date: Date = Date()) -> String {
        String(format: "%.0f¢", rate(for: date) * 100)
    }
    
    var isPeakRate: Bool {
        name == "Mid-Peak" || name == "On-Peak"
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
        return "\(startHour):00 - \(endHour):00"
    }
    
    func formattedRate(for date: Date = Date()) -> String {
        rateType.formattedRate(for: date)
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
    
    static func currentRateInfo(for date: Date = Date()) -> (rate: RateType, period: RatePeriod, nextPeriod: RatePeriod) {
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
        
        // Find the next period
        let nextPeriod: RatePeriod
        if let nextPeriodIndex = rates.firstIndex(where: { $0.startHour > calendar.component(.hour, from: date) }) {
            nextPeriod = rates[nextPeriodIndex]
        } else {
            // If no next period today, use first period of tomorrow
            nextPeriod = rates[0]
        }
        
        return (currentPeriod.rateType, currentPeriod, nextPeriod)
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
