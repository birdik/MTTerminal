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
    var candles: [Candle]?
    var maxHigh: Decimal {
        let maxHigh = self.candles?.map({ $0.high?.value ?? 0})
            .max() ?? 0
        CandlesResponse.maxHighStatic = maxHigh
        let maxVolume = self.candles?.map({ Decimal(string: ($0.volume ?? "0")) ?? 0 })
            .max() ?? 0
        CandlesResponse.maxVolumeStatic = maxVolume
        return maxHigh
    }
    var minLow: Decimal {
        let minLow = self.candles?.map({ $0.low?.value ?? 0})
            .min() ?? 0
        CandlesResponse.minLowStatic = minLow
        return minLow
    }
    var initialXScroll: String {
        if candles?.count ?? 0 > 50 {
            return candles?[((candles?.count ?? 0) - 50)].timeToData.formatted() ?? "0"
        } else {
            return candles?[0].timeToData.formatted() ?? "0"
        }
    }
    var axisMarks: [String] {
        guard let candles else {return [""]}
        var res = [candles.first?.timeToData.formatted() ?? "0"]
        if ((candles.count) / 10) > 1 {
            for i in 1...((candles.count) / 10) {
                res.append(candles[(i * 10) - 1].timeToData.formatted())
            }
        }
        return res
    }
    
    static var maxHighStatic: Decimal = 1
    static var minLowStatic: Decimal = 1
    static var maxVolumeStatic: Decimal = 1
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
    var color: Bool {
        return ((open?.value ?? 0) - (close?.value ?? 0)) > 0
    }
    var percent: String {
        ((close?.value ?? 0) * 100 / (open?.value ?? 0) - 100).formatted(Decimal.FormatStyle().precision(.fractionLength(2)))
    }
    var volumeMaxY: Decimal {
        let rangeYScale = (CandlesResponse.maxHighStatic - CandlesResponse.minLowStatic) / 5
        let volumeToDecimal = Decimal(string: (volume ?? "0")) ?? 0
        let resultMax = rangeYScale * (volumeToDecimal * 100 / CandlesResponse.maxVolumeStatic) / 100 + CandlesResponse.minLowStatic
        return resultMax
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
}
