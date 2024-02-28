//
//  FindInstrument.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 13.02.2024.
//

import SwiftUI

struct GetFindInstrument: Requests {
    let query: String
    var instrumentKind: String = "INSTRUMENT_TYPE_UNSPECIFIED"
    var apiTradeAvailableFlag: Bool = true
    var headURL = "InstrumentsService/FindInstrument"
}

struct FindInstrument: Codable {
    let instruments: [instrument?]?
    
    struct instrument: Codable {
        let isin: String?
        let figi: String?
        let ticker: String?
        let classCode: String?
        let instrumentType: String?
        let name: String?
        let uid: String?
        let positionUid: String?
        let instrumentKind: String?
        let apiTradeAvailableFlag: Bool?
        let forIisFlag: Bool?
        let first1minCandleDate: String
        let first1dayCandleDate: String
        let forQualInvestorFlag: Bool?
        let weekendFlag: Bool?
        let blockedTcaFlag:Bool?
        
        var instrumentKinds: String? {
            switch self.instrumentKind ?? "" {
            case "INSTRUMENT_TYPE_BOND":
                return "Облигация"
            case "INSTRUMENT_TYPE_SHARE":
                return "Акция"
            case "INSTRUMENT_TYPE_CURRENCY":
                return "Валюта"
            case "INSTRUMENT_TYPE_ETF":
                return "ETF"
            case "INSTRUMENT_TYPE_FUTURES":
                return "Фьючерс"
            case "INSTRUMENT_TYPE_SP":
                return "Структурная нота"
            case "INSTRUMENT_TYPE_OPTION":
                return "Опцион"
            case "INSTRUMENT_TYPE_CLEARING_CERTIFICATE":
                return "Clearing certificate"
            case "INSTRUMENT_TYPE_INDEX":
                return "Индекс"
            case "INSTRUMENT_TYPE_COMMODITY":
                return "Товар"
            default:
                return "Тип инструмента не определён"
            }
        }
    }
}
