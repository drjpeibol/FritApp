import Foundation

enum TimerType: String, CaseIterable, Identifiable {
    case amrap
    case emom
    case tabata
    case forTime
    
    var id: String { rawValue } // For Identifiable conformance
    
    var title: String {
        switch self {
        case .amrap: return "AMRAP"
        case .emom: return "EMOM"
        case .tabata: return "Tabata"
        case .forTime: return "For Time"
        }
    }
    
    var description: String {
        switch self {
        case .amrap: return "As Many Rounds As Possible"
        case .emom: return "Every Minute On the Minute"
        case .tabata: return "20s Work / 10s Rest"
        case .forTime: return "Complete For Time"
        }
    }
}

struct TimerSettings {
    var duration: TimeInterval
    var rounds: Int
    var workInterval: TimeInterval
    var restInterval: TimeInterval
    var isRunning: Bool
    
    static func defaultSettings(for type: TimerType) -> TimerSettings {
        switch type {
        case .amrap:
            return TimerSettings(duration: 600, rounds: 1, workInterval: 600, restInterval: 0, isRunning: false)
        case .emom:
            return TimerSettings(duration: 60, rounds: 10, workInterval: 60, restInterval: 0, isRunning: false)
        case .tabata:
            return TimerSettings(duration: 240, rounds: 8, workInterval: 20, restInterval: 10, isRunning: false)
        case .forTime:
            return TimerSettings(duration: 900, rounds: 1, workInterval: 900, restInterval: 0, isRunning: false)
        }
    }
}

struct WodGenerator {
    static let movements = [
        "Push-ups", "Pull-ups", "Air Squats", "Burpees", "Box Jumps",
        "Kettlebell Swings", "Wall Balls", "Thrusters", "Double-Unders",
        "Running", "Row", "Deadlifts", "Power Cleans", "Snatches"
    ]
    
    static let schemes = [
        "AMRAP in 10 minutes",
        "5 Rounds For Time",
        "EMOM for 10 minutes",
        "21-15-9 For Time",
        "Tabata Intervals"
    ]
    
    static func generateWOD() -> String {
        let scheme = schemes.randomElement()!
        var movements = Set<String>()
        
        // Select 3-4 random movements
        while movements.count < Int.random(in: 3...4) {
            movements.insert(Self.movements.randomElement()!)
        }
        
        let reps = [8, 10, 12, 15, 20].randomElement()!
        
        let movementsList = movements.map { "\(reps) \($0)" }.joined(separator: "\n")
        
        return """
        \(scheme)
        
        \(movementsList)
        """
    }
} 