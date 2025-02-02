import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    ProfileHeaderView()
                    
                    // Timeline and PRs sections
                    Text("Timeline and PRs coming soon")
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            Text("User Name")
                .font(.title2.bold())
        }
    }
} 