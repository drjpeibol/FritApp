import Foundation

class ProfileViewModel: ObservableObject {
    @Published var stats: TrainingStats
    @Published var personalRecords: [PersonalRecord]
    @Published var recentWorkouts: [WorkoutSession]
    @Published var selectedTimeRange: TimeRange = .month
    @Published var graphData: [MonthlyTraining] = []
    
    init() {
        // Create sample training data
        var trainingData: [Date: Double] = [:]
        let calendar = Calendar.current
        
        // Generate a year's worth of sample data
        for dayOffset in 0...365 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            trainingData[calendar.startOfDay(for: date)] = Double.random(in: 0.5...2.5)
        }
        
        // Initialize all stored properties first
        self.stats = TrainingStats(
            totalHours: 15.5,
            sessionsThisMonth: 12,
            averageSessionLength: 3600,
            trainingData: trainingData
        )
        
        self.personalRecords = [
            PersonalRecord(movement: "Back Squat", weight: 120, date: Date(), units: "kg"),
            PersonalRecord(movement: "Clean & Jerk", weight: 85, date: Date(), units: "kg"),
            PersonalRecord(movement: "Snatch", weight: 70, date: Date(), units: "kg")
        ]
        
        self.recentWorkouts = [
            WorkoutSession(date: Date(), type: .wod, duration: 3600,
                          description: "21-15-9\nThrusters (95/65 lb)\nPull-ups",
                          movements: ["Thrusters", "Pull-ups"]),
            WorkoutSession(date: Date().addingTimeInterval(-86400), type: .strength, duration: 2700,
                          description: "Back Squat 5x5\nAccessory Work",
                          movements: ["Back Squat"]),
            WorkoutSession(date: Date().addingTimeInterval(-172800), type: .conditioning, duration: 1800,
                          description: "5 Rounds For Time:\n400m Run\n15 Burpees",
                          movements: ["Run", "Burpees"])
        ]
        
        // After all properties are initialized, we can call methods
        self.graphData = stats.getTrainingData(for: .month)
    }
    
    func updateGraphData(for range: TimeRange) {
        selectedTimeRange = range
        graphData = stats.getTrainingData(for: range)
    }
} 