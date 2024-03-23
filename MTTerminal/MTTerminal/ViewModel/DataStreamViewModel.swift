//
//  MarketDataStreamModel.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 16.02.2024.
//

import SwiftUI

@Observable
final class MarketDataStream {
    var lastPrice: LastPrice?
    var orderbook: Orderbook?
    var trades: [Trade] = []
    var stream: SocketStream?
    let url = URL(string: "wss://invest-public-api.tinkoff.ru/ws/tinkoff.public.invest.api.contract.v1.MarketDataStreamService/MarketDataStream")!
    
    init() {
    }
    
    private enum SubscriptionAction: String {
        case subscribe = "SUBSCRIPTION_ACTION_SUBSCRIBE"
        case describe = "SUBSCRIPTION_ACTION_UNSUBSCRIBE"
    }
    
    private func sendLastPrice(user: User, action: SubscriptionAction) -> LastPriceRequest {
        let subscribeLastPriceRequest = SubscribeLastPriceRequest(subscriptionAction: action.rawValue, instruments: [Instrument(figi: user.figi, instrumentId: user.instrumentUid)])
        return LastPriceRequest(subscribeLastPriceRequest: subscribeLastPriceRequest)
    }
    
    private func sendOrderBook(user: User, depth: Int, action: SubscriptionAction) -> OrderBookRequest {
        let subscribeOrderBookRequest = SubscribeOrderBookRequest(subscriptionAction: action.rawValue, instruments: [InstrumentOrderBook(figi: user.figi, depth: depth, instrumentId: user.instrumentUid)])
        return OrderBookRequest(subscribeOrderBookRequest: subscribeOrderBookRequest)
    }
    
    private func sendTrades(user: User, action: SubscriptionAction) -> TradesRequest {
        let subscribeTradesRequest = SubscribeTradesRequest(subscriptionAction: action.rawValue, instruments: [Instrument(figi: user.figi, instrumentId: user.instrumentUid)])
        return TradesRequest(subscribeTradesRequest: subscribeTradesRequest)
    }
    
    private func receivedMarketData(data: MarketDataService) {
        switch data {
        case let x where x.orderbook != nil:
            orderbook = x.orderbook
            break
        case let x where x.lastPrice != nil:
            lastPrice = x.lastPrice
            break
        case let x where x.trade != nil:
            if trades.count < 100 {
                trades.append(x.trade!)
            } else {
                trades.removeFirst()
                trades.append(x.trade!)
            }
            break
        default:
            break
        }
    }
    
    deinit {
    }
}

extension MarketDataStream {
    @Sendable func startStream(user: User) async  throws {
        trades = []
        orderbook = nil
        lastPrice = nil
        stream = SocketStream()
        stream?.connect(token: user.token, url: url)
        try await stream?.sendMessage(sendTrades(user: user, action: .subscribe))
        try await stream?.sendMessage(sendOrderBook(user: user, depth: 20, action: .subscribe))
        try await stream?.sendMessage(sendLastPrice(user: user, action: .subscribe))
        for try await message in stream! {
            switch message {
            case let .string(string):
                let data = try JSONDecoder().decode(MarketDataService.self, from: Data(string.utf8))
                receivedMarketData(data: data)
            case .data(_):
                break
            @unknown default:
                break
            }
        }
    }
    
    func stopStream() {
        guard let stream else {return}
        stream.cancel()
    }
}
