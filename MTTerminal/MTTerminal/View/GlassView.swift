//
//  Glass.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 08.11.2023.
//

import SwiftUI

struct Glass: View {
    @Bindable var marketData: MarketDataStream
    @Bindable var dataAPI: GetDataAPI
    @Bindable var userView: UserView
    let defaultStyle = Decimal.FormatStyle().precision(.fractionLength(3))
    @Binding var price: Decimal?
    
    var body: some View {
        VStack {
            Text("Стакан")
                .font(.footnote)
                .foregroundStyle(Color("symbol"))
            Spacer()
            if marketData.orderbook == nil {
                Text("Нет данных")
                    .font(.footnote)
                    .lineLimit(1)
                    .foregroundStyle(.white)
            } else {
                ScrollView {
                    HStack {
                        Text(marketData.orderbook?.limitUp?.value?.formatted() ?? "0")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(marketData.orderbook?.spread.formatted(defaultStyle) ?? "0")%")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        Spacer()
                        Text(marketData.orderbook?.limitDown?.value?.formatted() ?? "0")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 5.0)
                    .cornerRadius(5)
                    HStack {
                        VStack {
                            ForEach(Array((marketData.orderbook?.bids ?? []).enumerated()), id: \.offset) { index, bid in
                                HStack {
                                    Text(bid.price?.value?.formatted() ?? "0" )
                                        .font(.footnote)
                                        .lineLimit(1)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    ForEach(dataAPI.orders?.orders ?? [], id: \.?.orderId) { order in
                                        if bid.price?.value == order?.initialSecurityPrice?.value {
                                            HStack {
                                                Text(order?.lotsLeft ?? "")
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                    .foregroundColor(Color.white)
                                                    .padding(.horizontal, 2.0)
                                            }
                                            .background(Color.blue)
                                            .cornerRadius(5)
                                            Spacer()
                                        }
                                    }
                                    Text(bid.quantity ?? "0")
                                        .font(.footnote)
                                        .lineLimit(1)
                                        .foregroundStyle(.white)
                                }
                                .background(marketData.orderbook?.linearGradientBids[index])
                                .onTapGesture {
                                    price = bid.price?.value
                                }
                            }
                        }
                        VStack {
                            ForEach(Array((marketData.orderbook?.asks ?? []).enumerated()), id: \.offset) { index, ask in
                                HStack {
                                    Text(ask.quantity ?? "0")
                                        .font(.footnote)
                                        .lineLimit(1)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    ForEach(dataAPI.orders?.orders ?? [], id: \.?.orderId) { order in
                                        if ask.price?.value == order?.initialSecurityPrice?.value {
                                            HStack {
                                                Text(order?.lotsLeft ?? "")
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                    .foregroundColor(Color.white)
                                                    .padding(.horizontal, 2.0)
                                            }
                                            .background(Color.blue)
                                            .cornerRadius(5)
                                            Spacer()
                                        }
                                    }
                                    Text(ask.price?.value?.formatted() ?? "0" )
                                        .font(.footnote)
                                        .lineLimit(1)
                                        .foregroundStyle(.white)
                                }
                                .background(marketData.orderbook?.linearGradientAsks[index])
                                .onTapGesture {
                                    price = ask.price?.value
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 5.0)
                }
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color("panel"))
        .cornerRadius(10)
        .task(id: userView.user.figi, getOrderBook)
    }

}


extension Glass {
    @Sendable private func getOrderBook() async {
        do {
            try await dataAPI.getOrderBook(user: userView.user)
            marketData.orderbook = Orderbook(figi: dataAPI.orderbook?.figi, depth: dataAPI.orderbook?.depth, isConsistent: true, bids: dataAPI.orderbook?.bids, asks: dataAPI.orderbook?.asks, time: dataAPI.orderbook?.time, limitUp: dataAPI.orderbook?.limitUp, limitDown: dataAPI.orderbook?.limitDown, instrumentUid: dataAPI.orderbook?.instrumentUid, orderBookType: "")
        } catch {
        }
    }
}
