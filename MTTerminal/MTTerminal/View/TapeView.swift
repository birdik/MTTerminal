//
//  Tape.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 08.11.2023.
//

import SwiftUI

struct Tape: View {
    @Bindable var marketData: MarketDataStream
    
    var body: some View {
        VStack {
            Text("Лента")
                .font(.footnote)
                .foregroundStyle(Color("symbol"))
            Spacer()
            ScrollView {
                ForEach(marketData.trades.reversed()) {trade in
                    HStack {
                        Text(trade.price?.value?.formatted() ?? "0")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(trade.quantity ?? "0")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(trade.amount ?? 0, specifier: "%.0f")")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        
                    }
                    .padding(.horizontal, 3.0)
                    .background(Color(trade.direction == "TRADE_DIRECTION_BUY" ? .green : .red))
                    .cornerRadius(5)
                    
                }
            }
            .padding(.horizontal, 5.0)
            Spacer()
        }
        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 0, maxHeight: .infinity)
        .background(Color("panel"))
        .cornerRadius(10)
    }
}

