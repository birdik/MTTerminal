//
//  OrderBook.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI

struct OrderBookRequest: Codable {
    let subscribeOrderBookRequest: SubscribeOrderBookRequest?
}

struct SubscribeOrderBookRequest: Codable {
    let subscriptionAction:  String
    let instruments: [InstrumentOrderBook]
}

struct InstrumentOrderBook: Codable {
    let figi: String
    let depth: Int
    let instrumentId: String
}

struct SubscribeOrderBookResponse: Codable {
    let trackingId: String?
    let orderBookSubscriptions: [OrderBookSubscriptions?]
    
    struct OrderBookSubscriptions: Codable {
        let figi: String?
        let depth: Int?
        let subscriptionStatus: String?
        let instrumentUid: String?
        let streamId: String?
        let subscriptionId: String?
        let orderBookType: String?
    }
}

struct Orderbook: Codable {
    let figi: String?
    let depth: Int?
    let isConsistent: Bool?
    let bids: [Order]?
    let asks: [Order]?
    let time: String?
    let limitUp: Quotation?
    let limitDown: Quotation?
    let instrumentUid: String?
    let orderBookType: String?
    var maxQuantity: Double {
        let numMaxBid = self.bids?.map({ Double($0.quantity ?? "0") ?? 0})
            .max()
        let numMaxAsk = self.asks?.map({ Double($0.quantity ?? "0") ?? 0})
            .max()
        
        return numMaxAsk ?? 0 > numMaxBid ?? 0 ? numMaxAsk ?? 0 : numMaxBid ?? 0
    }
    var linearGradientBids: [some View] {
        guard let linearGradientBids = self.bids?.map({
            let res = (Double($0.quantity ?? "0") ?? 0) / maxQuantity
            return LinearGradient(
                stops: [
                    .init(color: Color("panel"), location: 0),
                    .init(color: Color("panel"), location: 1-res),
                    .init(color: .green, location: 1-res),
                    .init(color: .green, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }) else { return [LinearGradient(
            stops: [
                .init(color: Color("panel"), location: 0),
                .init(color: Color("panel"), location: 1),
                .init(color: .green, location: 1),
                .init(color: .green, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )] }
        return linearGradientBids
    }
    var linearGradientAsks: [some View] {
        guard let linearGradientAsks = self.asks?.map({
            let res = (Double($0.quantity ?? "0") ?? 0) / maxQuantity
            return LinearGradient(
                stops: [
                    .init(color: .red, location: 0),
                    .init(color: .red, location: res),
                    .init(color: Color("panel"), location: res),
                    .init(color: Color("panel"), location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }) else { return [LinearGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .red, location: 1),
                .init(color: Color("panel"), location: 1),
                .init(color: Color("panel"), location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )] }
        return linearGradientAsks
    }
    
    var spread: Decimal {
        let res: Decimal = ((self.bids?.first?.price?.value ?? 0) / (self.asks?.first?.price?.value ?? 0)) * (-100) + 100
        return res
    }
}

struct Order: Codable {
    let price: Quotation?
    let quantity: String?
}
