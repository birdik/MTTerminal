//
//  GetOrderPrice.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 14.02.2024.
//

import SwiftUI

struct GetOrderPrice: Requests {    
    let accountId: String
    let instrumentId: String
    let price: Quotation
    let direction: String
    let quantity: String
    var headURL = "OrdersService/GetOrderPrice"
}

struct OrderPrice: Codable {
    let totalOrderAmount: MoneyValue?
    let lotsRequested: String?
    let initialOrderAmount: MoneyValue?
    let executedCommission: MoneyValue?
    let executedCommissionRub: MoneyValue?
    let dealCommission: MoneyValue?
    let serviceCommission: MoneyValue?
    let extraBond: ExtraBond?
    let extraFuture: ExtraFuture?
    
    struct ExtraBond: Codable {
        let aciValue: MoneyValue?
        let nominalConversionRate: Quotation?
    }
    
    struct ExtraFuture: Codable {
        let initialMargin: MoneyValue?
    }
}
