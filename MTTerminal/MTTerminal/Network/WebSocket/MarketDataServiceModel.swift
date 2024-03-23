//
//  MarketDataServiceModel.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI

struct MarketDataService: Codable {
    let subscribeLastPriceResponse: SubscribeLastPriceResponse?
    let lastPrice: LastPrice?
    let ping: Ping?
    let orderbook: Orderbook?
    let subscribeOrderBookResponse: SubscribeOrderBookResponse?
    let subscribeTradesResponse: SubscribeTradesResponse?
    let trade: Trade?
}

struct Ping: Codable {
    let time: String?
    let streamId: String?
}

