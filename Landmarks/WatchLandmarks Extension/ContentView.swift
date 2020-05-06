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
    
    func getHealthValues(store: HKHealthStore, sampleType: HKSampleType, completion: @escaping ([HKQuantitySample]) -> Void) {
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in

            guard let samples = results as? [HKQuantitySample] else {
                return
            }
            
            // Basically a callback
            DispatchQueue.main.async {
                completion(samples)
            }
        }

        store.execute(query)
    }

    var body: some View {
        
       print("Setting up health store...")
       let healthStore = HKHealthStore()

       let typesToShare: Set = [
           HKQuantityType.workoutType()
       ]

       let typesToRead: Set = [
           HKQuantityType.quantityType(forIdentifier: .heartRate)!,
           HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
           HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!,
           HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!,
           HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!,
           HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
           HKQuantityType.quantityType(forIdentifier: .vo2Max)!
       ]
        
       print("Getting user authorization for health metrics")
       healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
           // Handle error
       }
        
        do {
            let urlSession = URLSession(configuration: .default)
            let webSocketTask = urlSession.webSocketTask(with: URL(string: "ws://localhost:8080/ws/metrics")!)
            print("Opening Websocket connection to url: ws://localhost:8080/ws/metrics")
            webSocketTask.resume()

            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .running
            configuration.locationType = .outdoor
            
            let session: HKWorkoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder: HKLiveWorkoutBuilder = session.associatedWorkoutBuilder()
            
            // Set the datasource for the workout
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
             
            // Start the workout
            session.startActivity(with: Date())
            builder.beginCollection(withStart: Date()) { (success, error) in
               print("Beginning workout metric collection...")
            }
            
            HeartRatePublisher().publish(healthStore: healthStore)
          } catch {
            print("There was an error starting the workout")
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
