import SwiftUI

struct UtilitiesView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("WOD Generator") {
                    Text("WOD Generator coming soon")
                }
                
                NavigationLink("Timers") {
                    TimersView()
                }
            }
            .navigationTitle("Utilities")
        }
    }
}

struct TimersView: View {
    var body: some View {
        List {
            NavigationLink("AMRAP") {
                Text("AMRAP Timer coming soon")
            }
            NavigationLink("EMOM") {
                Text("EMOM Timer coming soon")
            }
            NavigationLink("Tabata") {
                Text("Tabata Timer coming soon")
            }
        }
        .navigationTitle("Timers")
    }
} 