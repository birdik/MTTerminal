//
//  LastTrades.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI

struct TradesRequest: Codable {
    let subscribeTradesRequest: SubscribeTradesRequest?
}

struct SubscribeTradesRequest: Codable {
    let subscriptionAction: String?
    let instruments: [Instrument]?
}

struct SubscribeTradesResponse: Codable {
    let trackingId: String?
    let tradeSubscriptions: [TradeSubscriptions?]?
    
    struct TradeSubscriptions: Codable {
        let figi: String?
        let subscriptionStatus: String?
        let instrumentUid: String?
        let streamId: String?
        let subscriptionId: String?
    }
}

struct Trade: Codable, Identifiable {
    let id = UUID()
    let figi: String?
    let direction: String?
    let price: Quotation?
    let quantity: String?
    let time: String?
    let instrumentUid: String?
    var amount: Double? {
        (Double("\(price?.value ?? 0)")! * (Double(quantity ?? "0"))!)
    }
    
    private enum CodingKeys: CodingKey {
        case figi, direction, price, quantity, time, instrumentUid
    }
}

