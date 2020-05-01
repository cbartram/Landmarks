//
//  ContentView.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 4/30/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        
       let healthStore = HKHealthStore()

       let typesToShare: Set = [
           HKQuantityType.workoutType()
       ]

       let typesToRead: Set = [
           HKQuantityType.quantityType(forIdentifier: .heartRate)!,
           HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
           HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
       ]

       healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
           // Handle error
       }
        
       return LandmarkList {
        WatchLandmarkDetail(landmark: $0)
       }.environmentObject(UserData())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
         LandmarkList { WatchLandmarkDetail(landmark: $0) }
                   .environmentObject(UserData())
    }
}
