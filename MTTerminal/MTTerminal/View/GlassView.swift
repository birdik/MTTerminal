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
    @Bindable var user: User
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
                            ForEach(marketData.orderbook?.bids ?? [], id:  \.price?.value) { bid in
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
                                .background(linearGradient(maxQuantity: marketData.orderbook?.maxQuantity ?? 0, quantity: bid.quantity ?? "0", color: .green))
                                .onTapGesture {
                                    price = bid.price?.value
                                }
                            }
                        }
                        VStack {
                            ForEach(marketData.orderbook?.asks ?? [], id:  \.price?.value) { ask in
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
                                .background(linearGradient(maxQuantity: marketData.orderbook?.maxQuantity ?? 0, quantity: ask.quantity ?? "0", color: .red))
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
        .onChange(of: user.figi, initial: true) {
            Task {
                do {
                    try await dataAPI.getOrderBook(token: user.token, instrumentId: user.instrumentUid, figi: user.figi)
                    marketData.orderbook = Orderbook(figi: dataAPI.orderbook?.figi, depth: dataAPI.orderbook?.depth, isConsistent: true, bids: dataAPI.orderbook?.bids, asks: dataAPI.orderbook?.asks, time: dataAPI.orderbook?.time, limitUp: dataAPI.orderbook?.limitUp, limitDown: dataAPI.orderbook?.limitDown, instrumentUid: dataAPI.orderbook?.instrumentUid, orderBookType: "")
                } catch {
                }
            }
        }
    }
    
    private func linearGradient(maxQuantity: Double, quantity: String, color: Color) -> some View {
        let res = (Double(quantity) ?? 0) / maxQuantity
        if color == .red {
            return LinearGradient(
                stops: [
                    .init(color: .red, location: 0),
                    .init(color: .red, location: res),
                    .init(color: Color("panel"), location: res),
                    .init(color: Color("panel"), location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                stops: [
                    .init(color: Color("panel"), location: 0),
                    .init(color: Color("panel"), location: 1-res),
                    .init(color: .green, location: 1-res),
                    .init(color: .green, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    }



