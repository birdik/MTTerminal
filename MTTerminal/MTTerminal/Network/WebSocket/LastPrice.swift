//
//  LastPrice.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI

struct LastPriceRequest: Codable {
    let subscribeLastPriceRequest: SubscribeLastPriceRequest
}

struct SubscribeLastPriceRequest: Codable {
    let subscriptionAction: String
    let instruments: [Instrument]
}

struct Instrument: Codable {
    let figi: String
    let instrumentId: String
}

struct SubscribeLastPriceResponse: Codable {
    let trackingId: String?
    let lastPriceSubscriptions: [LastPriceSubscription?]?
    
    struct LastPriceSubscription: Codable {
        let figi: String?
        let subscriptionStatus: String?
        let instrumentUid: String?
        let streamId: String?
        let subscriptionId: String?
    }
}


struct LastPrice: Codable {
    let figi: String?
    let price: Quotation?
    let time: String?
    let instrumentUid: String?
}

