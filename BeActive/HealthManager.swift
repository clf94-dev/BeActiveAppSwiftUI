//
//  File.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}

class HealthManager : ObservableObject {
    var healthStore: HKHealthStore?
    @Published var activities: [String: Activity] = [:]
    @Published var mockActivities: [String: Activity] = [
        "todaySteps": Activity(id: 0, title: "Today's steps", subtitle: "Goal: 10.000", amount: "12.123", image: "figure.walk.motion"),
        "todayCalories": Activity(id: 1, title: "Today calories", subtitle: "Goal: 600", amount: "1.241", image: "flame.fill")
        
    ]
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            
            let steps = HKQuantityType(.stepCount)
            let calories = HKQuantityType(.activeEnergyBurned)
            let healthTypes: Set = [steps, calories]
            
            Task {
                do {
                    try await healthStore?.requestAuthorization(toShare: [], read: healthTypes)
                    
                } catch {
                    print("error fetching the health data")
                }
            }
            fetchTodaySteps()
            fetchTodayCalories()
            
        }
    }
    func fetchTodaySteps () {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching today's step data")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Today's steps", subtitle: "Goal: 10.000", amount: stepCount.formattedString(), image: "figure.walk.motion")
            DispatchQueue.main.async{
                self.activities["todaySteps"] = activity
            }
        }
        healthStore?.execute(query)
    }
    func fetchTodayCalories(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching today's calories data")
                return
            }
            
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            let activity = Activity(id: 1, title: "Today calories", subtitle: "Goal: 600", amount: calorieCount.formattedString(), image: "flame.fill")
            DispatchQueue.main.async{
                self.activities["todayCalories"] = activity
            }
        }
        healthStore?.execute(query)
    }
    
}
