import Foundation

struct PersonalRecord: Identifiable {
    let id = UUID()
    let movement: String
    let weight: Double
    let date: Date
    let units: String
}

struct WorkoutSession: Identifiable {
    let id = UUID()
    let date: Date
    let type: WorkoutType
    let duration: TimeInterval
    let description: String
    let movements: [String]
}

enum WorkoutType: String {
    case wod = "WOD"
    case strength = "Strength"
    case skill = "Skill"
    case conditioning = "Conditioning"
}

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    case year = "Year"
    
    var numberOfDays: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        case .year: return 365
        }
    }
}

struct TrainingStats {
    let totalHours: Double
    let sessionsThisMonth: Int
    let averageSessionLength: TimeInterval
    let trainingData: [Date: Double] // Raw training data
    let streak: TrainingStreak
    
    // Computed property for graph data
    func getTrainingData(for range: TimeRange) -> [MonthlyTraining] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -range.numberOfDays, to: endDate)!
        
        var result: [MonthlyTraining] = []
        
        switch range {
        case .year, .sixMonths:
            // Group by months and calculate monthly averages
            var currentDate = startDate
            while currentDate <= endDate {
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
                let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
                
                var totalHours = 0.0
                var daysCount = 0
                
                var dayIterator = monthStart
                while dayIterator <= monthEnd && dayIterator <= endDate {
                    if let hours = trainingData[calendar.startOfDay(for: dayIterator)] {
                        totalHours += hours
                        daysCount += 1
                    }
                    dayIterator = calendar.date(byAdding: .day, value: 1, to: dayIterator)!
                }
                
                let monthlyAverage = daysCount > 0 ? totalHours / Double(daysCount) : 0
                result.append(MonthlyTraining(month: monthStart, hours: monthlyAverage))
                
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
            }
            
        case .month, .week:
            // Show daily data
            var currentDate = startDate
            while currentDate <= endDate {
                let dayStart = calendar.startOfDay(for: currentDate)
                let hours = trainingData[dayStart] ?? 0
                result.append(MonthlyTraining(month: dayStart, hours: hours))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        }
        
        return result
    }
}

struct MonthlyTraining: Identifiable {
    let id = UUID()
    let month: Date
    let hours: Double
}

struct TrainingStreak {
    let currentStreak: Int
    let longestStreak: Int
    let lastWorkoutDate: Date?
    
    static var empty: TrainingStreak {
        TrainingStreak(currentStreak: 0, longestStreak: 0, lastWorkoutDate: nil)
    }
} 