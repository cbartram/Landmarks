//
//  MockDataProducer.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit

class MockDataProducer {
    var store: HKHealthStore
    
    init(store: HKHealthStore) {
        self.store = store;
    }
    
    private func saveMockData() {
        
          let heartRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
          let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(arc4random_uniform(80) + 100))
          let heartSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: Date(), end: Date())

        print("Saving respiratory rate sample in HealthKit: ", heartSample)
        self.store.save(heartSample, withCompletion: { (success, error) in
          if let error = error {
            print("Error saving sample: \(error.localizedDescription)")
          }
            if success {
                print("Successfully saved sample: ", success)
            }
        })
      }
  
    func startMockData() {
      let _ = Timer.scheduledTimer(timeInterval: 1.0,
      target: self,
      selector: Selector(("saveMockData")),
      userInfo: nil,
      repeats: true)
    }
}
