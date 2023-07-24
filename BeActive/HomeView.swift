//
//  HomeView.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HealthManager
    // let welcomeArray = ["Welcome", "Bienvenido", "Bienvenue"]
    // @State private var currentIndex = 0
    var body: some View {
        
        ScrollView {
            VStack (alignment: .leading){
                Text("welcome")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.secondary)
                    // .animation(.easeOut(duration: 1), value: currentIndex)
                    //.onAppear{
                       // startWelcomeTimer()
                    // }
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                    ForEach(manager.activities.sorted(by: { $0.value.id <  $1.value.id} ), id: \.key){ item in
                        ActivityCard(activity: item.value)
                        
                    }
                }.padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    // func startWelcomeTimer() {
    //    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
    //        withAnimation {
    //            currentIndex = (currentIndex + 1) % welcomeArray.count
    //        }
    //    }
    //}
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HealthManager())
            .environment(\.locale, .init(identifier: "es"))
        HomeView()
            .environmentObject(HealthManager())
            .environment(\.locale, .init(identifier: "en"))
    }
}
