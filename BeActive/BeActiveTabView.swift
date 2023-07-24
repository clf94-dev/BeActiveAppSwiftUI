//
//  TabView.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import SwiftUI

struct BeActiveTabView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedTab = "Home"
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(manager)
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                }
                
            ChartView()
                .environmentObject(manager)
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                }
                

            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "person")
                }
        }
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        BeActiveTabView()
            .environmentObject(HealthManager())
    }
}
