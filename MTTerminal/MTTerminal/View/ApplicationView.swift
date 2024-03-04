//
//  Application.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 08.11.2023.
//

import SwiftUI

struct Application: View {
    @Binding var price: Decimal?
    @State private var lot: Decimal?
    @Binding var stream: SocketStream?
    @Bindable var marketData: MarketDataStream
    @Bindable var dataAPI: GetDataAPI
    @Bindable var user: User
    let defaultStyle = Decimal.FormatStyle().precision(.fractionLength(2))
    @State private var sheetFindInstrument = false
    @State private var sheetCandles = false
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    Button(user.ticker) {
                        sheetFindInstrument.toggle()
                    }
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .sheet(isPresented: $sheetFindInstrument) {
                        FindInstrumentView(user: user, dataAPI: dataAPI, stream: $stream)
                    }
                    Text(user.name)
                        .font(.footnote)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                }
                Spacer()
                Button {
                    sheetCandles.toggle()
                } label: {
                    VStack {
                        if marketData.lastPrice?.price?.value ?? 0 > 0 {
                            Text(marketData.lastPrice?.price?.value?.formatted() ?? "0")
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundStyle(.white)
                            Text("\(percentageDeviationDay(lastPrice: marketData.lastPrice?.price?.value ?? 0, eveningSessionPrice: dataAPI.closePrices?.closePrices?[0]?.eveningSessionPrice?.value ?? 0).formatted(defaultStyle))%")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(percentageDeviationDay(lastPrice: marketData.lastPrice?.price?.value ?? 0, eveningSessionPrice: dataAPI.closePrices?.closePrices?[0]?.eveningSessionPrice?.value ?? 0) > 0 ? .green : .red)
                            
                        } else {
                            Text(dataAPI.closePrices?.closePrices?[0]?.price?.value?.formatted() ?? "0")
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundStyle(.white)
                            Text("\(percentageDeviationDay(lastPrice: dataAPI.closePrices?.closePrices?[0]?.price?.value ?? 0, eveningSessionPrice: dataAPI.closePrices?.closePrices?[0]?.eveningSessionPrice?.value ?? 0).formatted(defaultStyle))%")
                                .font(.footnote)
                                .lineLimit(1)
                                .foregroundStyle(percentageDeviationDay(lastPrice: dataAPI.closePrices?.closePrices?[0]?.price?.value ?? 0, eveningSessionPrice: dataAPI.closePrices?.closePrices?[0]?.eveningSessionPrice?.value ?? 0) > 0 ? .green : .red)
                        }
                    }
                    .onChange(of: user.figi, initial: true) {
                        Task {
                            do {
                                try await dataAPI.getClosePrices(token: user.token, figi: user.figi)
                            } catch {
                            }
                        }
                    }
                }
                .sheet(isPresented: $sheetCandles) {
                    ChartView(dataAPI: dataAPI, user: user)
                }
            }
            .padding([.leading, .bottom, .trailing], 5.0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            ForEach(dataAPI.portfolio?.positions ?? [], id: \.positionUid) { position in
                if position.figi == user.figi {
                    HStack {
                            Text("\(position.quantity?.value?.formatted() ?? "0") lot")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.white)
                            Text(position.averagePositionPrice?.value?.formatted() ?? "0")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.white)
                            Text(position.expectedYield?.value?.formatted() ?? "0")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundColor(position.expectedYield?.value?.sign == .minus ? .red : .green)
                            Text("\(position.incomePercent.formatted(defaultStyle))%")
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundColor(position.incomePercent.sign == .minus ? .red : .green)
                    }
                    .onTapGesture {
                        if position.quantity?.value ?? 0 < 0 {
                            lot = (position.quantity?.value ?? 0) * (-1)
                        } else {
                            lot = position.quantity?.value
                        }
                    }
                }
            }
            HStack {
                VStack {
                    Text("Цена исполения")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    TextField("Price", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundStyle(.white)
                        .background(Color("background"))
                        .border(.black)
                        .cornerRadius(5)
                }
                .padding(.leading, 5.0)
                VStack {
                    Text("Количество")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    TextField("Lot", value: $lot, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundStyle(.white)
                        .background(Color("background"))
                        .border(.black)
                        .cornerRadius(5)
                    
                }
                .padding(.trailing, 5.0)
                
            }
            .padding(.top, 15.0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            HStack(alignment: .center) {
                if lot ?? 0 >= 1 && price ?? 0 > 0 {
                    Button {
                        lot = nil
                        price = nil
                    } label: {
                        Text("\(dataAPI.orderPrice?.initialOrderAmount?.value?.formatted() ?? "0")\(Currency(rawValue: dataAPI.orderPrice?.initialOrderAmount?.currency?.uppercased() ?? "USD")?.sign ?? "P")")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        Text("+ \(dataAPI.orderPrice?.executedCommission?.value?.formatted() ?? "0")\(Currency(rawValue: dataAPI.orderPrice?.executedCommission?.currency?.uppercased() ?? "USD")?.sign ?? "P")")
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 5.0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onChange(of: lot) {
                if lot ?? 0 > 0 && price ?? 0 > 0 {
                    Task {
                        do {
                            try await dataAPI.getOrderPrice(token: user.token, id: user.id, instrumentId: user.figi, price: price?.asQuotation ?? Quotation(nano: 0, units: "0"), direction: .buy, quantity: "\(lot ?? 0)")
                        } catch {
                        }
                    }
                }
            }
            .onChange(of: price) {
                if lot ?? 0 > 0 && price ?? 0 > 0 {
                    Task {
                        do {
                            try await dataAPI.getOrderPrice(token: user.token, id: user.id, instrumentId: user.figi, price: price?.asQuotation ?? Quotation(nano: 0, units: "0"), direction: .buy, quantity: "\(lot ?? 0)")
                        } catch {
                        }
                    }
                }
            }
            HStack {
                Button("Лим. покупка") {
                    if lot ?? 0 > 0 && price ?? 0 > 0 {
                        Task {
                            do {
                                try await dataAPI.postOrder(token: user.token, id: user.id, instrumentId: user.instrumentUid, figi: user.figi, price: price?.asQuotation ?? Quotation(nano: 0, units: "0"), direction: .buy, quantity: "\(lot ?? 0)", orderType: .limit)

                            } catch {
                                showingAlert = true
                            }
                        }
                    }
                }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(.green)
                    .cornerRadius(10)
                Button("Лим. продажа") {
                    Task {
                        if lot ?? 0 > 0 && price ?? 0 > 0 {
                            do {
                                try await dataAPI.postOrder(token: user.token, id: user.id, instrumentId: user.instrumentUid, figi: user.figi, price: price?.asQuotation ?? Quotation(nano: 0, units: "0"), direction: .sell, quantity: "\(lot ?? 0)", orderType: .limit)
                            } catch {
                                showingAlert = true
                            }
                        }
                    }
                }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 5.0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            HStack {
                Button("Рын. покупка") {
                    if lot ?? 0 > 0 && price ?? 0 > 0 {
                        Task {
                            do {
                                try await dataAPI.postOrder(token: user.token, id: user.id, instrumentId: user.instrumentUid, figi: user.figi, price: price?.asQuotation ?? Quotation(nano: 0, units: "0"), direction: .buy, quantity: "\(lot ?? 0)", orderType: .market)
                            } catch {
                                showingAlert = true
                            }
                        }
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(.green)
                .cornerRadius(10)
                Button("Рын. продажа") {
                    if lot ?? 0 > 0 && price ?? 0 > 0 {
                        Task {
                            do {
                                try await dataAPI.postOrder(token: user.token, id: user.id, instrumentId: user.instrumentUid, figi: user.figi, price: price?.asQuotation ?? Quotation(nano: 0, units: "0"), direction: .sell, quantity: "\(lot ?? 0)", orderType: .market)
                            } catch {
                                showingAlert = true
                            }
                        }
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(.red)
                .cornerRadius(10)
            }
            .padding(.horizontal, 5.0)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            Spacer()
        }
        .alert("Ошибка выставления ордера", isPresented: $showingAlert) {
            Button("ОК", role: .cancel) {}
        }
    }
    
    private func percentageDeviationDay(lastPrice: Decimal, eveningSessionPrice: Decimal) -> Decimal {
        return lastPrice/eveningSessionPrice * 100 - 100
    }
}

