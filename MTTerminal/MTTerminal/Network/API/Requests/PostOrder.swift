//
//  PostOrder.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 15.02.2024.
//

import SwiftUI

struct PostOrder: Requests {
    let figi: String
    let quantity: Int
    let price: Quotation
    let direction: String
    let accountId: String
    let orderType: String
    let instrumentId: String
    var headURL = "OrdersService/PostOrder"
}

struct OrderResponse: Codable {
    let orderId: String?
    let executionReportStatus: String?
    let lotsRequested: String
    let lotsExecuted: String
    let initialOrderPrice: MoneyValue?
    let executedOrderPrice: MoneyValue?
    let totalOrderAmount: MoneyValue?
    let initialCommission: MoneyValue?
    let executedCommission: MoneyValue?
    let aciValue: MoneyValue?
    let figi: String?
    let direction: String?
    let initialSecurityPrice: MoneyValue?
    let orderType: String?
    let message: String?
    let instrumentUid: String?
    let orderRequestId: String?
    let responseMetadata: ResponseMetadata?
    let initialOrderPricePt: Quotation?
    
    struct ResponseMetadata: Codable {
        let trackingId: String?
        let serverTime: String?
    }
    
}
