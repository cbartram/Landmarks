//
//  WebSocketPublisher.swift
//  WatchLandmarks Extension
//
//  Created by Christian Bartram on 5/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import HealthKit

class WebSocketPublisher {
    
    var webSocketTask: URLSessionWebSocketTask
    
    init() {
        let urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: URL(string: "ws://localhost:8080/ws/metrics")!)
        print("Opening Websocket connection to url: ws://localhost:8080/ws/metrics")
        webSocketTask.resume()
    }
    
    func publishMetric(forMetric: HKQuantityTypeIdentifier, value: Double) {
           let message = URLSessionWebSocketTask.Message.string("{ \"metric\": \"" + String(forMetric.rawValue) + "\", \"value\": \"" + String(format:"%.1f", value) + "\"}")
        self.webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket couldn’t send message because: \(error)")
                 }
            }
       }
}
