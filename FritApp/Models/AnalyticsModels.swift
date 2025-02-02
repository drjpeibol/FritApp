import Foundation

struct WorkoutAnalytics {
    let totalHours: Double
    let sessionsByType: [WorkoutCategory: Int]
    let movementFrequency: [String: Int]
    let periodSummary: PeriodSummary
}

enum WorkoutCategory: String, CaseIterable {
    case crossfit = "CrossFit"
    case weightlifting = "Weightlifting"
    case gymnastics = "Gymnastics"
    case endurance = "Endurance"
    
    var icon: String {
        switch self {
        case .crossfit: return "figure.highintensity.intervaltraining"
        case .weightlifting: return "dumbbell.fill"
        case .gymnastics: return "figure.gymnastics"
        case .endurance: return "figure.run"
        }
    }
}

struct MovementFrequency: Equatable {
    let name: String
    let count: Int
}

struct PeriodSummary {
    let totalSessions: Int
    let averageSessionLength: TimeInterval
    let mostFrequentMovement: MovementFrequency
    let leastFrequentMovement: MovementFrequency
} 