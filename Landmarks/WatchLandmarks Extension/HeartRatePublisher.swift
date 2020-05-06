//
//  HeartRatePublisher.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit


class HeartRatePublisher: WebSocketPublisher {
    func publish(healthStore: HKHealthStore) {
        guard let heartRateType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** This method should never fail ***")
        }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print("Error thrown when executing HK Observer query: ", error)
                return
            }
            
            let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: HKQueryAnchor(fromValue: 1), limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                
                 guard let samples = samplesOrNil as? [HKQuantitySample] else {
                       // Handle any errors here.
                       return
                   }
                     
                let lastSample = samples[samples.endIndex - 1]
                let sampleValue = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                let roundedValue = Double(round( 1 * sampleValue ) / 1)
                print("Publishing Heart Rate value: ", roundedValue)
                self.publishMetric(forMetric: HKQuantityTypeIdentifier.heartRate, value: roundedValue)
            }
            healthStore.execute(query)
        }
        healthStore.execute(query)
    }
}
