//
//  NetworkMonitorModel.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 26.02.2024.
//

import SwiftUI
import Network

@Observable
final class NetworkMonitor {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
     
    var isConnected = true
     
    init() {
        monitor.pathUpdateHandler =  { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}

