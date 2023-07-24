//
//  ChartView.swift
//  BeActive
//
//  Created by Carmen Lucas on 24/7/23.
//

import SwiftUI
import Charts

struct DailyStepView: Identifiable {
    let id = UUID()
    let date: Date
    let stepCount: Double
}

struct ChartView: View {
    @EnvironmentObject var manager: HealthManager
    var body: some View {
        VStack {
            if (manager.oneMonthChartData.count != 0) {
                Chart{
                    ForEach(manager.oneMonthChartData) { daily in
                        BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Steps", daily.stepCount))
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .environmentObject(HealthManager())
    }
}
