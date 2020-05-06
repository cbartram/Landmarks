//
//  RespiratoryRatePublisher.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit

class RespiratoryRatePublisher: WebSocketPublisher, Publisher {
    func publish(healthStore: HKHealthStore) {
        guard let respiratoryType = HKSampleType.quantityType(forIdentifier: .respiratoryRate) else {
            fatalError("*** This method should never fail ***")
        }
        
        let query = HKObserverQuery(sampleType: respiratoryType, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print("Error thrown when executing HK Observer query: ", error)
                return
            }
            
            let query = HKAnchoredObjectQuery(type: respiratoryType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
                
                 guard let samples = samplesOrNil as? [HKQuantitySample] else {
                       return
                   }
                
                if(samples.endIndex > 0) {
                    let lastSample = samples[samples.endIndex - 1]
                    let sampleValue = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                    let roundedValue = Double(round( 1 * sampleValue ) / 1)
                    print("Publishing Respiratory Rate value: ", roundedValue)
                    self.publishMetric(forMetric: HKQuantityTypeIdentifier.respiratoryRate, value: roundedValue)
                }
            }
            healthStore.execute(query)
        }
        healthStore.execute(query)
    }
}
