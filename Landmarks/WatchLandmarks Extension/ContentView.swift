//
//  ContentView.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 4/30/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import HealthKit

struct ContentView: View {
        
    var body: some View {
        
       print("Setting up health store...")
       let healthStore = HKHealthStore()

       let typesToShare: Set = [
           HKQuantityType.workoutType()
       ]

       let typesToRead: Set = [
           HKQuantityType.quantityType(forIdentifier: .heartRate)!,
           HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
           HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
       ]
        
       print("Getting user authorization for health metrics")
       healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
           // Handle error
       }
        
        do {
            let urlSession = URLSession(configuration: .default)
            let webSocketTask = urlSession.webSocketTask(with: URL(string: "ws://localhost:8080/ws/greetings")!)
            webSocketTask.resume()

            let message = URLSessionWebSocketTask.Message.string("Hello Socket")
            webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket sending error: \(error)")
                }
            }

            let configuration: HKWorkoutConfiguration = HKWorkoutConfiguration()
            let session: HKWorkoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder: HKLiveWorkoutBuilder = session.associatedWorkoutBuilder()
            
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
                    
            guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                fatalError("*** This method should never fail ***")
            }
            
            let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
                query, results, error in
                
                guard let samples = results as? [HKQuantitySample] else {
                    return
                }
                
                for sample in samples {
                    // Process each sample here.
                    let sampleValue = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    let roundedValue = Double( round( 1 * sampleValue ) / 1 )
//                    print("Rounded Value: ", roundedValue)
                }
            }
            
            healthStore.execute(query)
            
            
            let now: Date = Date();
            // Start the workout session and begin data collection.
            session.startActivity(with: now)
            builder.beginCollection(withStart: now) { (success, error) in
              print("Collecting Health Metrics...")
            }
          } catch {

          }
        
       print("Returning Landmark List View")
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
