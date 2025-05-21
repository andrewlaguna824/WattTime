import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingWidgetHelp = false
    @State private var isRefreshing = false
    @State private var currentRateInfo = EnergyData.currentRateInfo()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Current Rate Tab
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Rate Card
                        RateInfoView(rateInfo: currentRateInfo, style: .card)
                            .padding(.horizontal)
                        
                        // Rate Schedule
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today's Schedule")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(getTodaysRates(), id: \.startHour) { period in
                                        RatePeriodCard(period: period)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await refreshData()
                }
                .navigationTitle("WattTime")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingWidgetHelp = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .tabItem {
                Label("Current", systemImage: "bolt.fill")
            }
            .tag(0)
            
            // Settings Tab
            NavigationView {
                List {
                    Section("Widget") {
                        Button(action: { showingWidgetHelp = true }) {
                            Label("Add Widget", systemImage: "plus.circle.fill")
                        }
                    }
                    
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(1)
        }
        .sheet(isPresented: $showingWidgetHelp) {
            WidgetHelpView()
        }
    }
    
    private func getTodaysRates() -> [RatePeriod] {
        let calendar = Calendar.current
        let isWeekend = calendar.isDateInWeekend(Date())
        let month = calendar.component(.month, from: Date())
        let isWinter = (month >= 10 || month <= 5)

        if isWinter {
            return isWeekend ? EnergyData.winterWeekendRates : EnergyData.winterWeekdayRates
        } else {
            return isWeekend ? EnergyData.summerWeekendRates : EnergyData.summerWeekdayRates
        }
    }
    
    private func refreshData() async {
        // Add a small delay to show the refresh animation
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // Update the current rate info
        currentRateInfo = EnergyData.currentRateInfo()
    }
}

struct RatePeriodCard: View {
    let period: RatePeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(period.rateType.name)
                .font(.subheadline)
                .foregroundColor(period.rateType.color)
            
            Text(period.formattedRate())
                .font(.title3)
                .bold()
            
            Text(period.formattedTimeRange)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

struct WidgetHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Add Widget to Home Screen")
                    .font(.title2)
                    .bold()
                
                Text("1. Long press on your home screen\n2. Tap the + button\n3. Search for 'WattTime'\n4. Choose a widget size\n5. Tap 'Add Widget'")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
} 
