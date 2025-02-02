import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Range Selector
                    TimeRangeSelector(
                        selectedRange: viewModel.selectedTimeRange,
                        onRangeChanged: { range in
                            viewModel.updateTimeRange(range)
                        }
                    )
                    
                    // Total Training Time Card
                    TotalTimeCard(hours: viewModel.analytics.totalHours)
                    
                    // Workout Distribution Chart
                    WorkoutDistributionCard(sessionsByType: viewModel.analytics.sessionsByType)
                    
                    // Movement Analysis Card
                    MovementAnalysisCard(
                        mostFrequent: viewModel.analytics.periodSummary.mostFrequentMovement,
                        leastFrequent: viewModel.analytics.periodSummary.leastFrequentMovement
                    )
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
}

struct TimeRangeSelector: View {
    let selectedRange: TimeRange
    let onRangeChanged: (TimeRange) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Time Period")
                .font(.headline)
            
            Spacer()
            
            Menu {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(range.rawValue) {
                        onRangeChanged(range)
                    }
                }
            } label: {
                HStack {
                    Text(selectedRange.rawValue)
                        .foregroundColor(.accentColor)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.accentColor)
                }
                .frame(height: 44)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct TotalTimeCard: View {
    let hours: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Total Training Time", systemImage: "clock.fill")
                .font(.headline)
            
            Text("\(hours, specifier: "%.1f")")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            + Text(" hours")
                .font(.title2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct WorkoutDistributionCard: View {
    let sessionsByType: [WorkoutCategory: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Workout Distribution", systemImage: "chart.pie.fill")
                .font(.headline)
            
            Chart {
                ForEach(WorkoutCategory.allCases, id: \.self) { category in
                    SectorMark(
                        angle: .value("Sessions", sessionsByType[category] ?? 0),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Category", category.rawValue))
                }
            }
            .frame(height: 240)
            .animation(.easeInOut, value: sessionsByType)
            
            // Legend with counts
            VStack(spacing: 12) {
                ForEach(WorkoutCategory.allCases, id: \.self) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .frame(width: 24)
                        Text(category.rawValue)
                        Spacer()
                        Text("\(sessionsByType[category] ?? 0) sessions")
                            .foregroundColor(.secondary)
                            .animation(.easeInOut, value: sessionsByType[category])
                    }
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct MovementAnalysisCard: View {
    let mostFrequent: MovementFrequency
    let leastFrequent: MovementFrequency
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Movement Analysis", systemImage: "figure.strengthtraining.traditional")
                .font(.headline)
            
            VStack(spacing: 24) {
                MovementFrequencyRow(
                    title: "Most Practiced",
                    movement: mostFrequent.name,
                    count: mostFrequent.count,
                    icon: "arrow.up.circle.fill",
                    iconColor: .green
                )
                .transition(.scale.combined(with: .opacity))
                .id("most-\(mostFrequent.name)")
                
                MovementFrequencyRow(
                    title: "Least Practiced",
                    movement: leastFrequent.name,
                    count: leastFrequent.count,
                    icon: "arrow.down.circle.fill",
                    iconColor: .red
                )
                .transition(.scale.combined(with: .opacity))
                .id("least-\(leastFrequent.name)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .animation(.easeInOut, value: mostFrequent)
        .animation(.easeInOut, value: leastFrequent)
    }
}

struct MovementFrequencyRow: View {
    let title: String
    let movement: String
    let count: Int
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(movement)
                    .font(.headline)
                Spacer()
                Text("\(count) times")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut, value: count)
    }
} 