//
//  File.swift
//  BeActive
//
//  Created by Carmen Lucas on 23/7/23.
//

import Foundation
import HealthKit

class HealthManager : ObservableObject {
    var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            
            let steps = HKQuantityType(.stepCount)
            let healthTypes: Set = [steps]
            
            Task {
                do {
                    try await healthStore?.requestAuthorization(toShare: [], read: healthTypes)
                } catch {
                    print("error fetching the health data")
                }
            }
            
        }
    }
    
}
