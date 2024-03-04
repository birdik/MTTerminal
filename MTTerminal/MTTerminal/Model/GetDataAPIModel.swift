//
//  ContentViewModel.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI


@Observable
final class GetDataAPI {
    var accounts = Accounts(accounts: [])
    var portfolio: Portfolio?
    var closePrices: ClosePrices?
    var findInstrument: FindInstrument?
    var orders: Orders?
    var cancelOrder: CancelOrder?
    var orderPrice: OrderPrice?
    var order: OrderResponse?
    var orderbook: OrderBookResponse?
    var candles: CandlesResponse?
    
    init() {}
    
    func getAccounts (token: String) async throws {
        let getId = Request(data: GetEmptyData(), token: token)
        self.accounts = try await APIManager().answer(request: getId)
    }
    
    func getPortfolio(token: String, id: String) async throws {
        let getPortfolio = Request(data: GetPortfolio(accountId: id, currency: .ruble), token: token)
        self.portfolio = try await APIManager().answer(request: getPortfolio)
    }
    
    func getClosePrices(token: String, figi: String) async throws {
        let getClosePrices = Request(data: GetClosePrices(instruments: [instrument(instrumentId: figi)]), token: token)
        self.closePrices = try await APIManager().answer(request: getClosePrices)
    }
    
    func getFindInstrument(token: String, query: String) async throws {
        let getFindInstrument = Request(data: GetFindInstrument(query: query), token: token)
        self.findInstrument = try await APIManager().answer(request: getFindInstrument)
    }
    
    func getOrders(token: String, id: String) async throws {
        let getOrders = Request(data: GetOrders(accountId: id), token: token)
        self.orders = try await APIManager().answer(request: getOrders)
    }
    
    func getCancelOrder(token: String, id: String, orderId: String) async throws {
        let getCancelOrder = Request(data: GetCancelOrder(accountId: id, orderId: orderId), token: token)
        self.cancelOrder = try await APIManager().answer(request: getCancelOrder)
    }
    
    func getOrderPrice(token: String, id: String, instrumentId: String, price: Quotation, direction: OrderDirection, quantity: String ) async throws {
        let getOrderPrice = Request(data: GetOrderPrice(accountId: id, instrumentId: instrumentId, price: price, direction: direction.rawValue, quantity: quantity), token: token)
        self.orderPrice = try await APIManager().answer(request: getOrderPrice)
    }
    
    func postOrder(token: String, id: String, instrumentId: String, figi: String, price: Quotation, direction: OrderDirection, quantity: String, orderType: OrderType) async throws {
        let postOrder = Request(data: PostOrder(figi: figi, quantity: Int(quantity) ?? 0, price: price, direction: direction.rawValue, accountId: id, orderType: orderType.rawValue, instrumentId: instrumentId), token: token)
        self.order = try await APIManager().answer(request: postOrder)
    }
    
    func getOrderBook(token: String, instrumentId: String, figi: String) async throws {
        let getOrderBook = Request(data: GetOrderBook(figi: figi, depth: 20, instrumentId: instrumentId), token: token)
        self.orderbook = try await APIManager().answer(request: getOrderBook)
    }
    
    func getCandles(token: String, instrumentId: String, figi: String, interval: CandleInterval) async throws {
        let getCandles = Request(data: GetCandles(figi: figi, from: interval.dateToInterval.from, to: interval.dateToInterval.to, interval: interval.rawValue, instrumentId: instrumentId), token: token)
        self.candles = try await APIManager().answer(request: getCandles)
    }
}



