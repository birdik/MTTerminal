//
//  MoneyValue.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct MoneyValue: Codable {
    let nano: Int?
    let currency: String?
    let units: String?
    var value: Decimal? {
        let oneNumber = Decimal(string: units ?? "0") ?? 0
        let twoNumber = Decimal(sign: nano?.signum() == -1 ? .minus : .plus, exponent: -9, significand: Decimal(nano ?? 0))
        return oneNumber + twoNumber
    }
}

