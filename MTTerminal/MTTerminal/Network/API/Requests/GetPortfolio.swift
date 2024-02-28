//
//  GetPortfolio.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct GetPortfolio: Requests {
    let accountId: String
    let currency: Currency
    var headURL = "OperationsService/GetPortfolio"
}

struct Portfolio: Codable {
    let totalAmountBonds: MoneyValue?
    let totalAmountFutures: MoneyValue?
    let accountId: String?
    let totalAmountCurrencies: MoneyValue?
    let totalAmountSp: MoneyValue?
    let expectedYield: Quotation?
    let positions: [Position]?
    let totalAmountShares: MoneyValue?
    let totalAmountEtf: MoneyValue?
    let totalAmountPortfolio: MoneyValue?
    let virtualPositions: [VirtualPositions]?
    let totalAmountOptions: MoneyValue?
    
    struct Position: Codable {
        let varMargin: MoneyValue?
        let instrumentType: String?
        let quantity: Quotation?
        let averagePositionPricePt: Quotation?
        let expectedYieldFifo: Quotation?
        let averagePositionPriceFifo: MoneyValue?
        let currentPrice: MoneyValue?
        let positionUid: String?
        let figi: String?
        let quantityLots: Quotation?
        let blockedLots: Quotation?
        let averagePositionPrice: MoneyValue?
        let blocked: Bool?
        let instrumentUid: String?
        let currentNkd: MoneyValue?
        let expectedYield: Quotation?
        var cost: Decimal {
            (self.currentPrice?.value ?? 0) * (self.quantity?.value ?? 0)
        }
        var income: Decimal {
            (self.cost - ((self.quantity?.value ?? 0) * (self.averagePositionPrice?.value ?? 0)))
        }
        var incomePercent: Decimal {
            (self.cost / ((self.quantity?.value ?? 0) * (self.averagePositionPrice?.value ?? 0))) * 100 - 100
        }
    }
    
    struct VirtualPositions: Codable {
        let averagePositionPrice: MoneyValue?
        let instrumentType: String?
        let quantity: Quotation?
        let expectedYieldFifo: Quotation?
        let averagePositionPriceFifo: MoneyValue?
        let instrumentUid: String?
        let positionUid: String?
        let currentPrice: MoneyValue?
        let figi: String?
        let expectedYield: Quotation?
        let expireDate: String?
    }
    
}

