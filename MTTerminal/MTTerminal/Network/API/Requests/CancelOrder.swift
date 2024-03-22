//
//  CancelOrder.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 13.02.2024.
//

import SwiftUI

struct GetCancelOrder: Requests {
    let accountId: String
    let orderId: String
    var headURL = "OrdersService/CancelOrder"
}

struct CancelOrder: Codable {
    let time: String?
    let responseMetadata: ResponseMetadata?
    
    struct ResponseMetadata: Codable {
        let serverTime: String?
        let trackingId: String?
    }
}
