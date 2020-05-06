//
//  OxygenSaturationPublisher.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit

class OxygenSaturationPublisher: WebSocketPublisher, Publisher {
    func publish(healthStore: HKHealthStore) {
        guard let oxygenType = HKSampleType.quantityType(forIdentifier: .oxygenSaturation) else {
            fatalError("*** This method should never fail ***")
        }
        
        let query = HKObserverQuery(sampleType: oxygenType, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print("Error thrown when executing HK Observer query: ", error)
                return
            }
            
            let anchorQuery = HKAnchoredObjectQuery(type: oxygenType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                
                 guard let samples = samplesOrNil as? [HKQuantitySample] else {
                       return
                   }
                
                if(samples.endIndex > 0) {
                    let lastSample = samples[samples.endIndex - 1]
                    let sampleValue = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    let roundedValue = Double(round( 1 * sampleValue ) / 1)
                    print("Publishing Oxygen Saturation value: ", roundedValue)
                    self.publishMetric(forMetric: HKQuantityTypeIdentifier.oxygenSaturation, value: roundedValue)
                }
            }
            healthStore.execute(anchorQuery)
        }
        healthStore.execute(query)
    }
}
