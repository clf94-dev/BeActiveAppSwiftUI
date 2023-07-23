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
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        
        return calendar.date(from: components)!
        
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
            let workout = HKObjectType.workoutType()
            let healthTypes: Set = [steps, calories, workout]
            
            Task {
                do {
                    try await healthStore?.requestAuthorization(toShare: [], read: healthTypes)
                    fetchTodaySteps()
                    fetchTodayCalories()
                    fetchWeekStrengthStats()
                    fetchWeekRowingStats()
                    fetchWeekCoreStats()
                    
                } catch {
                    print("error fetching the health data")
                }
            }
            
            
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
            let activity = Activity(id: 0, title: "Today's steps", subtitle: "Goal: 10.000", amount: stepCount.formattedString(), image: "figure.walk")
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
    func fetchWeekStrengthStats () {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .functionalStrengthTraining)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: 20, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week strength training data")
                return
            }
            var count: Int = 0
            var countEnergy: Int = 0
            for workout in workouts {
                let duration = Int(workout.duration)/60
                count += duration
                countEnergy += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))
                
            }
            let activity = Activity(id: 2, title: "Strength", subtitle: "This week", amount: "\(count) minutes", image: "figure.strengthtraining.functional")
            DispatchQueue.main.async{
                self.activities["weekStrength"] = activity
            }
            let activityEnergy = Activity(id: 3, title: "Strength", subtitle: "Calories this week", amount: "\(countEnergy) kcal", image: "figure.strengthtraining.functional")
            DispatchQueue.main.async{
                self.activities["weekStrengthEnergy"] = activityEnergy
            }
            
        }
        healthStore?.execute(query)
    }
    func fetchWeekRowingStats () {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .rowing)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: 20, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week rowing training data")
                return
            }
            var count: Int = 0
            var countEnergy: Int = 0
            for workout in workouts {
                print(workout.duration)
                print(workout.sampleType)
                print(workout.totalEnergyBurned)

                
                let duration = Int(workout.duration)/60
                count += duration
                countEnergy += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))
                
            }
            let activity = Activity(id: 4, title: "Rowing", subtitle: "This week", amount: "\(count) minutes", image: "figure.rower")
            DispatchQueue.main.async{
                self.activities["weekRowing"] = activity
            }
            let activityEnergy = Activity(id: 5, title: "Rowing", subtitle: "Calories this week", amount: "\(countEnergy) kcal", image: "figure.rower")
            DispatchQueue.main.async{
                self.activities["weekRowingEnergy"] = activityEnergy
            }
            
        }
        healthStore?.execute(query)
    }
    func fetchWeekCoreStats () {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .coreTraining)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: 20, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week core training data")
                return
            }
            var count: Int = 0
            var countEnergy: Int = 0
            for workout in workouts {
                let duration = Int(workout.duration)/60
                count += duration
                countEnergy += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))
            }
            let activity = Activity(id: 6, title: "Core training", subtitle: "This week", amount: "\(count) minutes", image: "figure.core.training")
            DispatchQueue.main.async{
                self.activities["weekCore"] = activity
            }
            let activityEnergy = Activity(id: 7, title: "Core training", subtitle: "Calories this week", amount: "\(countEnergy) kcal", image: "figure.core.training")
            DispatchQueue.main.async{
                self.activities["weekCoreEnergy"] = activityEnergy
            }
            
        }
        healthStore?.execute(query)
    }

    
}
