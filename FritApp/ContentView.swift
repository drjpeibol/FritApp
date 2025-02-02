//
//  ContentView.swift
//  FritApp
//
//  Created by Pablo Serrano Molinero on 2/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
                .tag(0)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            UtilitiesView()
                .tabItem {
                    Label("Utilities", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(.primary) // Use system colors for a clean look
    }
}

#Preview {
    ContentView()
}
