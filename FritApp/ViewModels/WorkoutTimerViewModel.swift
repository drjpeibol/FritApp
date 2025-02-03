import Foundation
import Combine

class WorkoutTimerViewModel: ObservableObject {
    @Published var settings: TimerSettings
    @Published var remainingTime: TimeInterval
    @Published var currentRound: Int
    @Published var currentPhase: String
    
    private var timer: AnyCancellable?
    private let timerType: TimerType
    
    init(type: TimerType) {
        // Initialize all stored properties first
        self.timerType = type
        let initialSettings = TimerSettings.defaultSettings(for: type)
        self.settings = initialSettings
        self.remainingTime = initialSettings.duration
        self.currentRound = 1
        self.currentPhase = "Ready"
    }
    
    func toggleTimer() {
        settings.isRunning.toggle()
        
        if settings.isRunning {
            startTimer()
        } else {
            timer?.cancel()
        }
    }
    
    func resetTimer() {
        timer?.cancel()
        settings.isRunning = false
        remainingTime = settings.duration
        currentRound = 1
        currentPhase = "Ready"
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        guard remainingTime > 0 else {
            timer?.cancel()
            settings.isRunning = false
            return
        }
        
        remainingTime -= 1
        
        // Update phase and rounds based on timer type
        switch true {
        case settings.rounds > 1 && remainingTime.truncatingRemainder(dividingBy: settings.workInterval) == 0:
            currentRound = min(settings.rounds, Int(settings.duration - remainingTime) / Int(settings.workInterval) + 1)
            if currentRound <= settings.rounds {
                currentPhase = "Round \(currentRound)"
            }
        default:
            break
        }
    }
} 