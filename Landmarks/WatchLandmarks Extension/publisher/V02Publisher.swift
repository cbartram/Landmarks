//
//  V02Publisher.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit

class VO2Publisher: WebSocketPublisher, Publisher {
    func publish(healthStore: HKHealthStore) {
        guard let vo2Type = HKSampleType.quantityType(forIdentifier: .vo2Max) else {
            fatalError("*** This method should never fail ***")
        }
        
        let query = HKObserverQuery(sampleType: vo2Type, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print("Error thrown when executing HK Observer query: ", error)
                return
            }
            
            let anchorQuery = HKAnchoredObjectQuery(type: vo2Type, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                
                 guard let samples = samplesOrNil as? [HKQuantitySample] else {
                       return
                   }
                
                if(samples.endIndex > 0) {
                    let lastSample = samples[samples.endIndex - 1]
                    let sampleValue = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    let roundedValue = Double(round( 1 * sampleValue ) / 1)
                    print("Publishing V02 value: ", roundedValue)
                    self.publishMetric(forMetric: HKQuantityTypeIdentifier.bloodPressureSystolic, value: roundedValue)
                }
            }
            healthStore.execute(anchorQuery)
        }
        healthStore.execute(query)
    }
}
