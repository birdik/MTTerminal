//
//  GetOrderBook.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 16.02.2024.
//

import SwiftUI

struct GetOrderBook: Requests {
    let figi: String
    let depth: Int
    let instrumentId: String
    var headURL = "MarketDataService/GetOrderBook"
}

struct OrderBookResponse: Codable {
    let figi: String?
    let depth: Int?
    let isConsistent: Bool?
    let bids: [Order]?
    let asks: [Order]?
    let time: String?
    let lastPrice: Quotation?
    let closePrice: Quotation?
    let limitUp: Quotation?
    let limitDown: Quotation?
    let instrumentUid: String?
    let lastPriceTs: String?
    let closePriceTs: String?
    let orderbookTs: String?
    var maxQuantity: Double {
        let numMaxBid = self.bids?.map({ Double($0.quantity ?? "0") ?? 0})
            .max()
        let numMaxAsk = self.asks?.map({ Double($0.quantity ?? "0") ?? 0})
            .max()
        return numMaxAsk ?? 0 > numMaxBid ?? 0 ? numMaxAsk ?? 0 : numMaxBid ?? 0
    }
    var spread: Decimal {
        let res: Decimal = ((self.bids?.first?.price?.value ?? 0) / (self.asks?.first?.price?.value ?? 0)) * (-100) + 100
        return res
    }
}
