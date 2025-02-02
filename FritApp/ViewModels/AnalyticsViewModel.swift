import Foundation

class AnalyticsViewModel: ObservableObject {
    @Published var analytics: WorkoutAnalytics
    @Published var selectedTimeRange: TimeRange = .month
    
    private var allData: [Date: WorkoutAnalytics]
    
    init() {
        // First, initialize all stored properties
        self.allData = AnalyticsViewModel.generateSampleData()
        
        // Create initial analytics with empty data
        self.analytics = WorkoutAnalytics(
            totalHours: 0,
            sessionsByType: [:],
            movementFrequency: [:],
            periodSummary: PeriodSummary(
                totalSessions: 0,
                averageSessionLength: 0,
                mostFrequentMovement: MovementFrequency(name: "None", count: 0),
                leastFrequentMovement: MovementFrequency(name: "None", count: 0)
            )
        )
        
        // After initialization, update with actual data
        DispatchQueue.main.async {
            self.analytics = self.aggregateData(for: .month)
        }
    }
    
    private static func generateSampleData() -> [Date: WorkoutAnalytics] {
        var data: [Date: WorkoutAnalytics] = [:]
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0...365 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let multiplier = Double.random(in: 0.5...1.5)
            let mostFrequent = MovementFrequency(name: "Squats", count: Int(70 * multiplier))
            let leastFrequent = MovementFrequency(name: "Running", count: Int(15 * multiplier))
            
            data[date] = WorkoutAnalytics(
                totalHours: 0.5 * multiplier,
                sessionsByType: [
                    .crossfit: Int(15 * multiplier),
                    .weightlifting: Int(10 * multiplier),
                    .gymnastics: Int(5 * multiplier),
                    .endurance: Int(7 * multiplier)
                ],
                movementFrequency: [
                    "Pull-ups": Int(40 * multiplier),
                    "Squats": Int(70 * multiplier),
                    "Push-ups": Int(50 * multiplier),
                    "Running": Int(15 * multiplier),
                    "Deadlifts": Int(25 * multiplier)
                ],
                periodSummary: PeriodSummary(
                    totalSessions: Int(37 * multiplier),
                    averageSessionLength: 3600,
                    mostFrequentMovement: mostFrequent,
                    leastFrequentMovement: leastFrequent
                )
            )
        }
        
        return data
    }
    
    func updateTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
        analytics = aggregateData(for: range)
    }
    
    private func aggregateData(for range: TimeRange) -> WorkoutAnalytics {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -range.numberOfDays, to: endDate)!
        
        var totalHours = 0.0
        var sessionsByType: [WorkoutCategory: Int] = [:]
        var movementFrequency: [String: Int] = [:]
        var totalSessions = 0
        
        // Aggregate data within the date range
        allData.forEach { date, analytics in
            if date >= startDate && date <= endDate {
                totalHours += analytics.totalHours
                
                // Aggregate sessions by type
                analytics.sessionsByType.forEach { type, count in
                    sessionsByType[type, default: 0] += count
                }
                
                // Aggregate movement frequency
                analytics.movementFrequency.forEach { movement, count in
                    movementFrequency[movement, default: 0] += count
                }
                
                totalSessions += analytics.periodSummary.totalSessions
            }
        }
        
        // Find most and least frequent movements
        let sortedMovements = movementFrequency.sorted { $0.value > $1.value }
        let mostFrequent = sortedMovements.first.map { MovementFrequency(name: $0.key, count: $0.value) } 
            ?? MovementFrequency(name: "None", count: 0)
        let leastFrequent = sortedMovements.last.map { MovementFrequency(name: $0.key, count: $0.value) } 
            ?? MovementFrequency(name: "None", count: 0)
        
        return WorkoutAnalytics(
            totalHours: totalHours,
            sessionsByType: sessionsByType,
            movementFrequency: movementFrequency,
            periodSummary: PeriodSummary(
                totalSessions: totalSessions,
                averageSessionLength: 3600,
                mostFrequentMovement: mostFrequent,
                leastFrequentMovement: leastFrequent
            )
        )
    }
} 