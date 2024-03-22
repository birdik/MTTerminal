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
    
    func getAccounts (user: User) async throws {
        let getId = Request(data: GetEmptyData(), token: user.token)
        self.accounts = try await APIManager().answer(request: getId)
    }
    
    func getPortfolio(user: User) async throws {
        let getPortfolio = Request(data: GetPortfolio(accountId: user.id, currency: .ruble), token: user.token)
        self.portfolio = try await APIManager().answer(request: getPortfolio)
    }
    
    func getClosePrices(user: User) async throws {
        let getClosePrices = Request(data: GetClosePrices(instruments: [instrument(instrumentId: user.figi)]), token: user.token)
        self.closePrices = try await APIManager().answer(request: getClosePrices)
    }
    
    func getFindInstrument(user: User, query: String) async throws {
        let getFindInstrument = Request(data: GetFindInstrument(query: query), token: user.token)
        self.findInstrument = try await APIManager().answer(request: getFindInstrument)
    }
    
    func getOrders(user: User) async throws {
        let getOrders = Request(data: GetOrders(accountId: user.id), token: user.token)
        self.orders = try await APIManager().answer(request: getOrders)
    }
    
    func getCancelOrder(user: User, orderId: String) async throws {
        let getCancelOrder = Request(data: GetCancelOrder(accountId: user.id, orderId: orderId), token: user.token)
        self.cancelOrder = try await APIManager().answer(request: getCancelOrder)
    }
    
    func getOrderPrice(user: User, price: Quotation, direction: OrderDirection, quantity: String ) async throws {
        let getOrderPrice = Request(data: GetOrderPrice(accountId: user.id, instrumentId: user.instrumentUid, price: price, direction: direction.rawValue, quantity: quantity), token: user.token)
        self.orderPrice = try await APIManager().answer(request: getOrderPrice)
    }
    
    func postOrder(user: User, price: Quotation, direction: OrderDirection, quantity: String, orderType: OrderType) async throws {
        let postOrder = Request(data: PostOrder(figi: user.figi, quantity: Int(quantity) ?? 0, price: price, direction: direction.rawValue, accountId: user.id, orderType: orderType.rawValue, instrumentId: user.instrumentUid), token: user.token)
        self.order = try await APIManager().answer(request: postOrder)
    }
    
    func getOrderBook(user: User) async throws {
        let getOrderBook = Request(data: GetOrderBook(figi: user.figi, depth: 20, instrumentId: user.instrumentUid), token: user.token)
        self.orderbook = try await APIManager().answer(request: getOrderBook)
    }
    
    func getCandles(user: User, interval: CandleInterval) async throws {
        let getCandles = Request(data: GetCandles(figi: user.figi, from: interval.dateToInterval.from, to: interval.dateToInterval.to, interval: interval.rawValue, instrumentId: user.instrumentUid), token: user.token)
        self.candles = try await APIManager().answer(request: getCandles)
    }
}



