//
//  ActivityCard.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import SwiftUI

struct ActivityCard: View {
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .cornerRadius(15)
            VStack (spacing: 15){
                HStack (alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Daily steps")
                            .font(.system(size: 16))
                        
                        Text("Goal: 10.000")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "figure.walk.motion")
                        .foregroundColor(.green)
                }
                
                
                Text("6.234")
                    .font(.system(size: 24))
            }
            .padding()
            .cornerRadius(15)
        }
        
    }
}

struct ActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCard()
    }
}
