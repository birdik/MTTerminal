//
//  Order.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 15.02.2024.
//

import SwiftUI

enum OrderDirection: String {
    case non = "ORDER_DIRECTION_UNSPECIFIED"
    case buy = "ORDER_DIRECTION_BUY"
    case sell = "ORDER_DIRECTION_SELL"
}

enum OrderType: String {
    case non = "ORDER_TYPE_UNSPECIFIED"
    case limit = "ORDER_TYPE_LIMIT"
    case market = "ORDER_TYPE_MARKET"
    case bestprice = "ORDER_TYPE_BESTPRICE"
}
