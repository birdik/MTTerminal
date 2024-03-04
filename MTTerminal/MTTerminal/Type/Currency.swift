//
//  Currency.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

enum Currency: String, Codable {
    case ruble = "RUB"
    case dollar = "USD"
    case euro = "EUR"
    
    public var sign: String {
        switch self {
        case .ruble: return "₽"
        case .euro: return "€"
        case .dollar: return "$"
        }
    }
}

