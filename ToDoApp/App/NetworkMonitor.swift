//
//  NetworkMonitor.swift
//  ToDoApp
//
//  Created by Huseyin Jafarli on 15.09.25.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    public private(set) var isConnected: Bool = false
    public var didChangeStatus: ((Bool) -> Void)?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status == .satisfied
            self.didChangeStatus?(self.isConnected)
        }
        monitor.start(queue: queue)
    }
}
