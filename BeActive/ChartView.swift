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

enum ChartOptions {
    case oneWeek
    case twoWeek
    case oneMonth
    case threeMonth
    case yearToDate
    case oneYear
}

struct ChartView: View {
    @EnvironmentObject var manager: HealthManager
    @State var selectedChart: ChartOptions = .oneMonth
    var body: some View {
        VStack {
            if (manager.oneMonthChartData.count != 0) {
                ScrollView {
                    
                
                Chart{
                    ForEach(manager.oneMonthChartData) { daily in
                        BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Steps", daily.stepCount))
                    }
                }
                .foregroundColor(.green)
                .frame(height: 350)
                .padding(.horizontal)
                
                    HStack{
                        Button("1W"){
                            withAnimation {
                                selectedChart = .oneWeek
                            }
                        }
                        .padding()
                        .foregroundColor(selectedChart == .oneWeek ? .white : .green)
                        .background(selectedChart == .oneWeek ? .green : .clear)
                        .cornerRadius(10)
                        Button("2W"){
                            withAnimation {
                                selectedChart = .twoWeek
                            }
                        }
                        .padding()
                        .foregroundColor(selectedChart == .twoWeek ? .white : .green)
                        .background(selectedChart == .twoWeek ? .green : .clear)
                        .cornerRadius(10)
                        Button("1M"){
                            withAnimation {
                                selectedChart = .oneMonth
                            }
                        }
                        .padding()
                        .foregroundColor(selectedChart == .oneMonth ? .white : .green)
                        .background(selectedChart == .oneMonth ? .green : .clear)
                        .cornerRadius(10)
                        Button("3M"){
                            withAnimation {
                                selectedChart = .threeMonth
                            }
                        }
                        .padding()
                        .foregroundColor(selectedChart == .threeMonth ? .white : .green)
                        .background(selectedChart == .threeMonth ? .green : .clear)
                        .cornerRadius(10)
                        Button("YTD"){
                            withAnimation {
                                selectedChart = .yearToDate
                            }
                        }
                        .padding()
                        .foregroundColor(selectedChart == .yearToDate ? .white : .green)
                        .background(selectedChart == .yearToDate ? .green : .clear)
                        .cornerRadius(10)
                        Button("1Y"){
                            withAnimation {
                                selectedChart = .oneYear
                            }
                        }
                        .padding()
                        .foregroundColor(selectedChart == .oneYear ? .white : .green)
                        .background(selectedChart == .oneYear ? .green : .clear)
                        .cornerRadius(10)




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
