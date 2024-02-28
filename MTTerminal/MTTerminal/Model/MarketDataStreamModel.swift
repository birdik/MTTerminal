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
    let url = URL(string: "wss://invest-public-api.tinkoff.ru/ws/tinkoff.public.invest.api.contract.v1.MarketDataStreamService/MarketDataStream")!
    
    init() {
    }
    
    enum SubscriptionAction: String {
        case subscribe = "SUBSCRIPTION_ACTION_SUBSCRIBE"
        case describe = "SUBSCRIPTION_ACTION_UNSUBSCRIBE"
    }
    
    func sendLastPrice(instrumentId: String, figi: String, action: SubscriptionAction) -> LastPriceRequest {
        let subscribeLastPriceRequest = SubscribeLastPriceRequest(subscriptionAction: action.rawValue, instruments: [Instrument(figi: figi, instrumentId: instrumentId)])
        return LastPriceRequest(subscribeLastPriceRequest: subscribeLastPriceRequest)
    }
    
    func sendOrderBook(instrumentId: String, figi: String, depth: Int, action: SubscriptionAction) -> OrderBookRequest {
        let subscribeOrderBookRequest = SubscribeOrderBookRequest(subscriptionAction: action.rawValue, instruments: [InstrumentOrderBook(figi: figi, depth: depth, instrumentId: instrumentId)])
        return OrderBookRequest(subscribeOrderBookRequest: subscribeOrderBookRequest)
    }
    
    func sendTrades(instrumentId: String, figi: String, action: SubscriptionAction) -> TradesRequest {
        let subscribeTradesRequest = SubscribeTradesRequest(subscriptionAction: action.rawValue, instruments: [Instrument(figi: figi, instrumentId: instrumentId)])
        return TradesRequest(subscribeTradesRequest: subscribeTradesRequest)
    }
    
    func receivedMarketData(data: MarketDataService) {
        switch data {
        case let x where x.orderbook != nil:
            orderbook = x.orderbook
            break
        case let x where x.lastPrice != nil:
            lastPrice = x.lastPrice
            break
        case let x where x.trade != nil:
            if self.trades.count < 100 {
                self.trades.append(x.trade!)
            } else {
                self.trades.removeFirst()
                self.trades.append(x.trade!)
            }
            break
        default:
            break
        }
    }
    
    deinit {
    }
}
