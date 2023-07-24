//
//  ActivityCard.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let amount: String
    let image: String
    let tintColor: Color

}

struct ActivityCard: View {
    @State var activity: Activity
    var body: some View {
        ZStack {
            Color(UIColor(activity.tintColor))
                .cornerRadius(15)
                .opacity(0.3)
            VStack (spacing: 15){
                HStack (alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(activity.title)
                            .font(.system(size: 16))
                        
                        Text(activity.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: activity.image)
                        .foregroundColor(activity.tintColor)
                }
                
                
                Text(activity.amount)
                    .font(.system(size: 24))
                    .minimumScaleFactor(0.6)
                    .bold()
                    .padding(.bottom)
            }
            .padding()
            .cornerRadius(15)
        }
        
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal: 10.000", amount: "6.234", image: "figure.walk.motion", tintColor: .green))
    }
}
