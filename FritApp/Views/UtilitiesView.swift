import SwiftUI

struct UtilitiesView: View {
    @State private var generatedWOD: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        WODGeneratorView()
                    } label: {
                        UtilityRow(
                            title: "WOD Generator",
                            icon: "dumbbell.fill",
                            description: "Generate random workouts"
                        )
                    }
                }
                
                Section("Timers") {
                    ForEach([TimerType.amrap, .emom, .tabata, .forTime]) { type in
                        NavigationLink {
                            WorkoutTimerView(type: type)
                        } label: {
                            UtilityRow(
                                title: type.title,
                                icon: "timer",
                                description: type.description
                            )
                        }
                    }
                }
            }
            .navigationTitle("Utilities")
        }
    }
}

struct UtilityRow: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct WODGeneratorView: View {
    @State private var generatedWOD: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if generatedWOD.isEmpty {
                    ContentUnavailableView(
                        "Generate a WOD",
                        systemImage: "dumbbell.fill",
                        description: Text("Tap the button below to generate a random workout")
                    )
                } else {
                    Text(generatedWOD)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                
                Button(action: {
                    withAnimation {
                        generatedWOD = WodGenerator.generateWOD()
                    }
                }) {
                    Label("Generate WOD", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("WOD Generator")
    }
}

struct WorkoutTimerView: View {
    let type: TimerType
    @StateObject private var viewModel: WorkoutTimerViewModel
    
    init(type: TimerType) {
        self.type = type
        _viewModel = StateObject(wrappedValue: WorkoutTimerViewModel(type: type))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Timer Display
            TimerDisplayView(
                remainingTime: viewModel.remainingTime,
                currentRound: viewModel.currentRound,
                totalRounds: viewModel.settings.rounds,
                phase: viewModel.currentPhase
            )
            
            // Controls
            if !viewModel.settings.isRunning {
                TimerSettingsView(settings: $viewModel.settings, type: type)
            }
            
            // Start/Pause Button
            Button(action: {
                viewModel.toggleTimer()
            }) {
                Label(viewModel.settings.isRunning ? "Pause" : "Start",
                      systemImage: viewModel.settings.isRunning ? "pause.fill" : "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            if viewModel.settings.isRunning {
                Button("Reset", role: .destructive) {
                    viewModel.resetTimer()
                }
            }
        }
        .padding()
        .navigationTitle(type.title)
    }
}

struct TimerDisplayView: View {
    let remainingTime: TimeInterval
    let currentRound: Int
    let totalRounds: Int
    let phase: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(timeString(from: remainingTime))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            if totalRounds > 1 {
                Text("Round \(currentRound) of \(totalRounds)")
                    .font(.title3)
            }
            
            Text(phase)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TimerSettingsView: View {
    @Binding var settings: TimerSettings
    let type: TimerType
    
    var body: some View {
        VStack(spacing: 16) {
            if type == .amrap || type == .forTime {
                TimerSettingRow(
                    title: "Duration",
                    value: Int(settings.duration) / 60,
                    range: 1...60,
                    unit: "min"
                ) { newValue in
                    settings.duration = TimeInterval(newValue * 60)
                }
            }
            
            if type == .emom {
                TimerSettingRow(
                    title: "Rounds",
                    value: settings.rounds,
                    range: 1...30,
                    unit: "rounds"
                ) { newValue in
                    settings.rounds = newValue
                }
            }
            
            if type == .tabata {
                TimerSettingRow(
                    title: "Work Interval",
                    value: Int(settings.workInterval),
                    range: 10...60,
                    unit: "sec"
                ) { newValue in
                    settings.workInterval = TimeInterval(newValue)
                }
                
                TimerSettingRow(
                    title: "Rest Interval",
                    value: Int(settings.restInterval),
                    range: 5...30,
                    unit: "sec"
                ) { newValue in
                    settings.restInterval = TimeInterval(newValue)
                }
            }
        }
    }
}

struct TimerSettingRow: View {
    let title: String
    let value: Int
    let range: ClosedRange<Int>
    let unit: String
    let onChange: (Int) -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: .init(
                get: { value },
                set: { onChange($0) }
            )) {
                ForEach(range, id: \.self) { value in
                    Text("\(value) \(unit)").tag(value)
                }
            }
        }
    }
} 