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
    static var oneMonthAgo: Date {
        let calendar = Calendar.current
        let oneMonth = calendar.date(byAdding: .month, value: -1, to: Date())
        
        return calendar.startOfDay(for: oneMonth!)
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
    @Published var weekActivities: [String: Activity] = [:]
    @Published var mockActivities: [String: Activity] = [
        "todaySteps": Activity(id: 0, title: "Today's steps", subtitle: "Goal: 10.000", amount: "12.123", image: "shoeprints.fill", tintColor: .green),
        "todayCalories": Activity(id: 1, title: "Today calories", subtitle: "Goal: 600", amount: "1.241", image: "flame.fill", tintColor: .red)
        
    ]
    
    @Published var oneMonthChartData = [DailyStepView]()
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            
            let steps = HKQuantityType(.stepCount)
            let calories = HKQuantityType(.activeEnergyBurned)
            let workout = HKObjectType.workoutType()
            let water = HKQuantityType(.dietaryWater)
            let exercise = HKQuantityType(.appleExerciseTime)

            let healthTypes: Set = [steps, calories, workout, water, exercise]
            
            Task {
                do {
                    try await healthStore?.requestAuthorization(toShare: [], read: healthTypes)
                   fetchTodayStats()
                    // fetchWeekStrengthStats()
                    // fetchWeekRowingStats()
                    // fetchWeekCoreStats()
                    fetchCurrentWeekWorkoutStats()
                    fetchPastMonthStepData()
                    
                } catch {
                    print("error fetching the health data")
                }
            }
            
            
        }
    }
    func fetchDailySteps(startDate: Date, completion: @escaping ([DailyStepView]) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: nil, anchorDate: startDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, result, error in
            guard let result = result else {
                completion([])
                return
            }
            
            var dailySteps = [DailyStepView]()
            
            result.enumerateStatistics(from: startDate, to: Date()) { statistics, stop in
                
                dailySteps.append(DailyStepView(date: statistics.startDate, stepCount: statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0.00))
            }
            
            completion(dailySteps)
            
            
        }
        healthStore?.execute(query)
        
    }
    
    // MARK: Today's stats
    func fetchTodayStats () {
        fetchTodaySteps()
        fetchTodayCalories()
        // fetchTodayWaterIntake()
        fetchTodayExerciseTime()
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
            let activity = Activity(id: 0, title: "today steps", subtitle: "Goal: \(10000)", amount: stepCount.formattedString(), image: "shoeprints.fill", tintColor: .green)
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
            let activity = Activity(id: 1, title: "today calories", subtitle: "Goal: \(600)", amount: calorieCount.formattedString(), image: "flame.fill", tintColor: .red)
            DispatchQueue.main.async{
                self.activities["todayCalories"] = activity
            }
        }
        healthStore?.execute(query)
    }
    func fetchTodayWaterIntake() {
        let water = HKQuantityType(.dietaryWater)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: water, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching today's water intake data")
                return
            }
            
            let waterCount = quantity.doubleValue(for: .liter())
            let activity = Activity(id: 2, title: "water", subtitle: "Goal: \(600)", amount: waterCount.formattedString(), image: "water.fill", tintColor: .blue)
            DispatchQueue.main.async{
                self.activities["todayWater"] = activity
            }

        }
        healthStore?.execute(query)
    }
    func fetchTodayExerciseTime() {
        let exerciseTime = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: exerciseTime, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching today's exercise time data")
                return
            }
            
            let exerciseTimeCount = quantity.doubleValue(for: .minute())
            let activity = Activity(id: 3, title: "exercise time", subtitle: "Goal: \(30)", amount: exerciseTimeCount.formattedString(), image: "figure.run", tintColor: .green)
            DispatchQueue.main.async{
                self.activities["todayExerciseTime"] = activity
            }

        }
        healthStore?.execute(query)
    }

    
    // MARK: Workouts weekly stats
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
            let activity = Activity(id: 2, title: "strength", subtitle: "this week", amount: "\(count) minutes", image: "figure.strengthtraining.functional", tintColor: .orange)
            DispatchQueue.main.async{
                self.activities["weekStrength"] = activity
            }
            let activityEnergy = Activity(id: 3, title: "strength", subtitle: "calories this week", amount: "\(countEnergy) kcal", image: "figure.strengthtraining.functional", tintColor: .orange)
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
                let duration = Int(workout.duration)/60
                count += duration
                countEnergy += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))
                
            }
            let activity = Activity(id: 4, title: "rowing", subtitle: "this week", amount: "\(count) minutes", image: "figure.rower", tintColor: .cyan)
            DispatchQueue.main.async{
                self.activities["weekRowing"] = activity
            }
            let activityEnergy = Activity(id: 5, title: "rowing", subtitle: "calories this week", amount: "\(countEnergy) kcal", image: "figure.rower", tintColor: .cyan)
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
            let activity = Activity(id: 6, title: "Core training", subtitle: "This week", amount: "\(count) minutes", image: "figure.core.training", tintColor: .purple)
            DispatchQueue.main.async{
                self.activities["weekCore"] = activity
            }
            let activityEnergy = Activity(id: 7, title: "Core training", subtitle: "Calories this week", amount: "\(countEnergy) kcal", image: "figure.core.training", tintColor: .purple)
            DispatchQueue.main.async{
                self.activities["weekCoreEnergy"] = activityEnergy
            }
            
        }
        healthStore?.execute(query)
    }
    
    func fetchCurrentWeekWorkoutStats () {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workout, predicate: timePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week core training data")
                return
            }
            var countStrength: Int = 0
            var countEnergyStrength: Int = 0
            var countRowing: Int = 0
            var countEnergyRowing: Int = 0
            var countCore: Int = 0
            var countEnergyCore: Int = 0
            var countWalking: Int = 0
            var countDistanceWalking: Int = 0
            
            for workout in workouts {
                if workout.workoutActivityType == .functionalStrengthTraining {
                    let duration = Int(workout.duration)/60
                    countStrength += duration
                    countEnergyStrength += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))
                    
                } else if workout.workoutActivityType == .rowing {
                    let duration = Int(workout.duration)/60
                    countRowing += duration
                    countEnergyRowing += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))

                } else if workout.workoutActivityType == .coreTraining {
                    let duration = Int(workout.duration)/60
                    countCore += duration
                    countEnergyCore += Int(workout.totalEnergyBurned!.doubleValue(for: .kilocalorie()))

                } else if workout.workoutActivityType == .walking {
                    let duration = Int(workout.duration)/60
                    countWalking += duration
                    countDistanceWalking += Int(workout.totalDistance!.doubleValue(for: .meter()))

                }
                
               
            }
            let activityStrength = Activity(id: 5, title: "strength", subtitle: "this week", amount: "\(countStrength) minutes", image: "figure.strengthtraining.functional", tintColor: .orange)
            
            let activityStrengthEnergy = Activity(id: 6, title: "strength", subtitle: "calories this week", amount: "\(countEnergyStrength) kcal", image: "figure.strengthtraining.functional", tintColor: .orange)
            
            let activityRowing = Activity(id: 7, title: "rowing", subtitle: "this week", amount: "\(countRowing) minutes", image: "figure.rower", tintColor: .cyan)
            
            let activityRowingEnergy = Activity(id: 8, title: "rowing", subtitle: "calories this week", amount: "\(countEnergyRowing) kcal", image: "figure.rower", tintColor: .cyan)
            
            let activityCore = Activity(id: 9, title: "core training", subtitle: "this week", amount: "\(countCore) minutes", image: "figure.core.training", tintColor: .purple)
            
            let activityCoreEnergy = Activity(id: 10, title: "core training", subtitle: "calories this week", amount: "\(countEnergyCore) kcal", image: "figure.core.training", tintColor: .purple)
            let activityWalking = Activity(id: 11, title: "walking", subtitle: "this week", amount: "\(countWalking) minutes", image: "figure.walk.motion", tintColor: .mint)
            
            let activityWalkingEnergy = Activity(id: 12, title: "walking", subtitle: "distance this week", amount: "\(countDistanceWalking) m", image: "figure.walk.motion", tintColor: .mint)
            

            

            DispatchQueue.main.async{
                self.weekActivities["weekStrength"] = activityStrength
                self.weekActivities["weekStrengthEnergy"] = activityStrengthEnergy
                self.weekActivities["weekRowing"] = activityRowing
                self.weekActivities["weekRowingEnergy"] = activityRowingEnergy
                self.weekActivities["weekCore"] = activityCore
                self.weekActivities["weekCoreEnergy"] = activityCoreEnergy
                self.weekActivities["weekWalking"] = activityWalking
                self.weekActivities["weekWalkingEnergy"] = activityWalkingEnergy
            }
            
        }
        healthStore?.execute(query)
        
    }

    
    // MARK: Refresh data outside of init

    func refreshData() {
        fetchTodaySteps()
        fetchTodayCalories()
        // fetchWeekStrengthStats()
        // fetchWeekRowingStats()
        // fetchWeekCoreStats()
        fetchCurrentWeekWorkoutStats()
        fetchPastMonthStepData()
    }
    
}



// MARK: Chart Data

extension HealthManager {
    func fetchPastMonthStepData() {
        fetchDailySteps(startDate: .oneMonthAgo) { dailySteps in
            DispatchQueue.main.async {
                self.oneMonthChartData = dailySteps
            }
        }
    }
    
}
