//
//  Publisher.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit

protocol Publisher {
    func publish(healthStore: HKHealthStore) -> Void
}
