//
//  GetOrders.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 13.02.2024.
//

import SwiftUI

struct GetOrders: Requests {
    let accountId: String?
    var headURL = "OrdersService/GetOrders"
}

struct Orders: Codable {
    let orders: [OrderState?]?
}

struct OrderState: Codable {
    let orderId: String?
    let executionReportStatus: String?
    let lotsRequested: String?
    let lotsExecuted: String?
    let initialOrderPrice: MoneyValue?
    let executedOrderPrice: MoneyValue?
    let totalOrderAmount: MoneyValue?
    let averagePositionPrice: MoneyValue?
    let initialCommission: MoneyValue?
    let executedCommission: MoneyValue?
    let figi: String?
    let direction: String?
    let initialSecurityPrice: MoneyValue?
    let stages: [Stage?]?
    let serviceCommission: MoneyValue?
    let currency: String?
    let orderType: String?
    let orderDate: String?
    let instrumentUid: String?
    let orderRequestId: String?
    var lotsLeft: String {
        let result = (Int64(self.lotsRequested ?? "0") ?? 0) - (Int64(self.lotsExecuted ?? "0") ?? 0)
        return "\(result)"
    }
}

struct Stage: Codable {
    let quantity: String?
    let price: MoneyValue?
    let tradeId: String?
}


