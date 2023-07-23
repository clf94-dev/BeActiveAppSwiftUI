//
//  HomeView.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager
    var body: some View {
        VStack{
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ActivityCard(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal: 10.000", amount: "6.534", image: "figure.walk.motion"))
                ActivityCard(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal: 10.000", amount: "6.234", image: "figure.walk.motion"))
            }.padding(.horizontal)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
