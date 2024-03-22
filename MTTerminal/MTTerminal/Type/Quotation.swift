//
//  Quotation.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct Quotation: Codable, Hashable {
    let nano: Int?
    let units: String?
    var value: Decimal? {
        let oneNumber = Decimal(string: units ?? "0") ?? 0
        let twoNumber = Decimal(sign: nano?.signum() == -1 ? .minus : .plus, exponent: -9, significand: Decimal(nano ?? 0))
        return oneNumber + twoNumber
    }
    
}

extension Decimal {
    func rounded(_ roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var number = self
        NSDecimalRound(&result, &number, 0, roundingMode)
        return result
    }
    var whole: Decimal { rounded(sign == .minus ? .up : .down) }
    var fraction: Decimal { self - whole }
    
    var asQuotation: Quotation {
        let units = String("\(self.whole)")
        let nano = Int(truncating: (self.fraction * 1_000_000_000 as NSDecimalNumber))
        return Quotation(nano: nano, units: units)
    }
}
