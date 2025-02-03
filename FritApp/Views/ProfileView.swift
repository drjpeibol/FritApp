import SwiftUI
import Charts

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeaderView()
                    
                    // Add streak view after header
                    StreakView(streak: viewModel.stats.streak)
                    
                    // Monthly Statistics Card
                    StatisticsCardView(stats: viewModel.stats)
                    
                    // Training Hours Graph
                    TrainingGraphView(
                        monthlyData: viewModel.graphData,
                        onRangeChanged: { range in
                            viewModel.updateGraphData(for: range)
                        }
                    )
                    
                    // Personal Records Section
                    PersonalRecordsView(records: viewModel.personalRecords)
                    
                    // Recent Workouts
                    RecentWorkoutsView(workouts: viewModel.recentWorkouts)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { /* Add edit profile action */ }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            Text("User Name")
                .font(.title2.bold())
        }
    }
}

struct StatisticsCardView: View {
    let stats: TrainingStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("This Month")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 24) {
                StatItem(value: String(format: "%.1f", stats.totalHours),
                        label: "Hours",
                        icon: "clock.fill")
                
                StatItem(value: "\(stats.sessionsThisMonth)",
                        label: "Sessions",
                        icon: "flame.fill")
                
                StatItem(value: String(format: "%.1f", stats.averageSessionLength/3600),
                        label: "Avg Hours",
                        icon: "chart.bar.fill")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title2.bold())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct TrainingGraphView: View {
    let monthlyData: [MonthlyTraining]
    @State private var selectedTimeRange: TimeRange = .month
    let onRangeChanged: (TimeRange) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with 44pt minimum touch target
            HStack(alignment: .center, spacing: 16) {
                Text("Training Hours")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(range.rawValue) {
                            selectedTimeRange = range
                            onRangeChanged(range)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedTimeRange.rawValue)
                            .foregroundColor(.accentColor)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.accentColor)
                    }
                    .frame(height: 44) // Minimum touch target
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(chartTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart(monthlyData) { item in
                    BarMark(
                        x: .value("Date", item.month, unit: selectedTimeRange == .year || selectedTimeRange == .sixMonths ? .month : .day),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(Color.accentColor)
                    // Add spacing between bars
                    .cornerRadius(6)
                }
                .frame(height: 220) // Taller for better visibility
                .chartXAxis {
                    AxisMarks(values: .stride(by: selectedTimeRange == .week ? .day : .month)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                if selectedTimeRange == .week {
                                    Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                        .font(.footnote)
                                } else {
                                    Text(date.formatted(.dateTime.month(.abbreviated)))
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray.opacity(0.3))
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text(String(format: "%.1f", hours))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                // Add proper padding around the chart
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var chartTitle: String {
        switch selectedTimeRange {
        case .year, .sixMonths:
            return "Average daily hours per month"
        case .month, .week:
            return "Daily training hours"
        }
    }
}

struct PersonalRecordsView: View {
    let records: [PersonalRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Personal Records")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {
                    // Action to see all PRs
                }
                .font(.subheadline)
            }
            
            ForEach(records.prefix(3)) { record in
                PRRow(record: record)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct PRRow: View {
    let record: PersonalRecord
    
    var body: some View {
        HStack {
            Text(record.movement)
            Spacer()
            Text("\(record.weight, specifier: "%.1f") \(record.units)")
                .bold()
        }
    }
}

struct RecentWorkoutsView: View {
    let workouts: [WorkoutSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Workouts")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {
                    // Action to see all workouts
                }
                .font(.subheadline)
            }
            
            ForEach(workouts.prefix(3)) { workout in
                WorkoutRow(workout: workout)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct WorkoutRow: View {
    let workout: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.type.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
            }
            
            Text(workout.description)
                .lineLimit(2)
        }
    }
}

struct StreakView: View {
    let streak: TrainingStreak
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Training Streak", systemImage: "flame.fill")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("\(streak.currentStreak)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Current")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("\(streak.longestStreak)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Best")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let lastWorkout = streak.lastWorkoutDate {
                    VStack(spacing: 8) {
                        Text(lastWorkout, style: .date)
                            .font(.system(size: 16, weight: .semibold))
                        Text("Last Workout")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
} 