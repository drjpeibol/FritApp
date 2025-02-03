import Foundation

class ProfileViewModel: ObservableObject {
    @Published var stats: TrainingStats
    @Published var personalRecords: [PersonalRecord]
    @Published var recentWorkouts: [WorkoutSession]
    @Published var selectedTimeRange: TimeRange = .month
    @Published var graphData: [MonthlyTraining] = []
    
    // Move streak calculation to static methods
    private static func calculateStreak(from workouts: [WorkoutSession]) -> TrainingStreak {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort workouts by date
        let sortedWorkouts = workouts.sorted { $0.date > $1.date }
        guard let lastWorkout = sortedWorkouts.first?.date else {
            return .empty
        }
        
        let lastWorkoutDay = calendar.startOfDay(for: lastWorkout)
        
        // If last workout was more than a day ago, streak is broken
        guard calendar.dateComponents([.day], from: lastWorkoutDay, to: today).day ?? 0 <= 1 else {
            return TrainingStreak(
                currentStreak: 0,
                longestStreak: calculateLongestStreak(from: sortedWorkouts),
                lastWorkoutDate: lastWorkout
            )
        }
        
        // Calculate current streak
        var currentStreak = 1
        var checkDate = calendar.date(byAdding: .day, value: -1, to: lastWorkoutDay)!
        
        for workout in sortedWorkouts.dropFirst() {
            let workoutDate = calendar.startOfDay(for: workout.date)
            
            if calendar.isDate(workoutDate, inSameDayAs: checkDate) {
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                currentStreak += 1
            } else if workoutDate > checkDate {
                break
            }
        }
        
        return TrainingStreak(
            currentStreak: currentStreak,
            longestStreak: calculateLongestStreak(from: sortedWorkouts),
            lastWorkoutDate: lastWorkout
        )
    }
    
    private static func calculateLongestStreak(from workouts: [WorkoutSession]) -> Int {
        let calendar = Calendar.current
        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        // Group workouts by date to handle multiple workouts per day
        let workoutDates = Set(workouts.map { calendar.startOfDay(for: $0.date) })
        let sortedDates = workoutDates.sorted(by: <)
        
        for date in sortedDates {
            if let last = lastDate {
                let dayDifference = calendar.dateComponents([.day], from: last, to: date).day ?? 0
                
                if dayDifference == 1 {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            
            lastDate = date
        }
        
        return max(longestStreak, currentStreak)
    }
    
    init() {
        // Create sample data first
        let workouts = [
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
        
        let records = [
            PersonalRecord(movement: "Back Squat", weight: 120, date: Date(), units: "kg"),
            PersonalRecord(movement: "Clean & Jerk", weight: 85, date: Date(), units: "kg"),
            PersonalRecord(movement: "Snatch", weight: 70, date: Date(), units: "kg")
        ]
        
        var trainingData: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for dayOffset in 0...365 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date())!
            trainingData[calendar.startOfDay(for: date)] = Double.random(in: 0.5...2.5)
        }
        
        // Calculate streak using static method
        let streak = Self.calculateStreak(from: workouts)
        
        // Initialize all properties
        self.recentWorkouts = workouts
        self.personalRecords = records
        self.stats = TrainingStats(
            totalHours: 15.5,
            sessionsThisMonth: 12,
            averageSessionLength: 3600,
            trainingData: trainingData,
            streak: streak
        )
        
        // Initialize graph data
        self.graphData = stats.getTrainingData(for: .month)
    }
    
    func updateGraphData(for range: TimeRange) {
        selectedTimeRange = range
        graphData = stats.getTrainingData(for: range)
    }
} 