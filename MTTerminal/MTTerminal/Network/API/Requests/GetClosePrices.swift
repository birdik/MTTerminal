//
//  GetClosePrices.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 13.02.2024.
//

import SwiftUI

struct GetClosePrices: Requests {
    let instruments: [instrument]
    var headURL = "MarketDataService/GetClosePrices"
}

struct instrument: Codable, Hashable {
    let instrumentId: String
}

struct ClosePrices: Codable {
    let closePrices: [closePrices?]?
    
    struct closePrices: Codable {
        let figi: String?
        let instrumentUid: String?
        let price: Quotation?
        let eveningSessionPrice: Quotation?
        let time: String?
    }
}
