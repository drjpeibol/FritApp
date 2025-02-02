import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Placeholder for feed items
                    Text("Feed coming soon")
                }
                .padding()
            }
            .navigationTitle("Feed")
        }
    }
} 