//
//  File.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 16.02.2024.
//

import SwiftUI

struct GetCandles: Requests {
    let figi: String
    let from: String
    let to: String
    let interval: String
    let instrumentId: String
    var headURL = "MarketDataService/GetCandles"
}

struct CandlesResponse: Codable {
    let candles: [Candle]?
    var maxHigh: Decimal {
        let a = self.candles?.map({ $0.high?.value ?? 0})
            .max() ?? 0
        return a + a / 100
    }
    var minLow: Decimal {
        let a = self.candles?.map({ $0.low?.value ?? 0})
            .min() ?? 0
        return a - a / 100
    }
}

struct Candle: Codable {
    let open: Quotation?
    let high: Quotation?
    let low: Quotation?
    let close: Quotation?
    let volume: String?
    let time: String?
    let isComplete: Bool?
    var timeToData: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: time ?? "2019-12-01T12:12:12Z")!
    }
}

enum CandleInterval: String, Codable {
    case oneMin = "CANDLE_INTERVAL_1_MIN"
    case fiveMin = "CANDLE_INTERVAL_5_MIN"
    case fifteenMin = "CANDLE_INTERVAL_15_MIN"
    case thirtyMin = "CANDLE_INTERVAL_30_MIN"
    case hour = "CANDLE_INTERVAL_HOUR"
    case fourHour = "CANDLE_INTERVAL_4_HOUR"
    case day = "CANDLE_INTERVAL_DAY"
    case week = "CANDLE_INTERVAL_WEEK"
    case month = "CANDLE_INTERVAL_MONTH"
    
    public var dateToInterval: (from: String, to: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        switch self {
        case .oneMin:
            return ("\(dateFormatter.string(from: Date()))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .fiveMin:
            return ("\(dateFormatter.string(from: Date()))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .fifteenMin:
            return ("\(dateFormatter.string(from: Date()))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .thirtyMin:
            return ("\(dateFormatter.string(from: Date() - 86400))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .hour:
            return ("\(dateFormatter.string(from: Date() - 518400))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .fourHour:
            return ("\(dateFormatter.string(from: Date() - 2592000))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .day:
            return ("\(dateFormatter.string(from: Date() - 31536000))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .week:
            return ("\(dateFormatter.string(from: Date() - 63072000))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        case .month:
            return ("\(dateFormatter.string(from: Date() - 315360000))T00:00:00.000Z", "\(dateFormatter.string(from: Date() + 86400))T00:00:00.000Z")
        }
    }
    
    public var chartLength: Int {
        switch self {
        case .oneMin: return 60 * 60
        case .fiveMin: return 60 * 60 * 5
        case .fifteenMin: return 60 * 60 * 15
        case .thirtyMin: return 60 * 60 * 30
        case .hour: return 60 * 60 * 60
        case .fourHour: return 60 * 60 * 60 * 4
        case .day: return 60 * 60 * 60 * 24
        case .week: return 60 * 60 * 60 * 24 * 7
        case .month: return 60 * 60 * 60 * 24 * 30
        }
    }
}
