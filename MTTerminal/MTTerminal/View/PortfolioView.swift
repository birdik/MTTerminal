//
//  PortfolioView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 01.02.2024.
//

import SwiftUI

struct PortfolioView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var userView: UserView
    @Bindable var dataAPI: GetDataAPI
    @Bindable var marketData: MarketDataStream
    let defaultStyle = Decimal.FormatStyle().precision(.fractionLength(2))
    
    var body: some View {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Label("Назад", systemImage: "chevron.backward")
                            .padding(.top, 5.0)
                    }
                    Spacer()
                }
                Text("Портфель")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5.0)
                    .foregroundStyle(.white)
                
                HStack {
                    Text("Брокерский счет:")
                        .foregroundStyle(.white)
                    Text("\(dataAPI.portfolio?.totalAmountPortfolio?.value ?? 0, format: .currency(code: dataAPI.portfolio?.totalAmountPortfolio?.currency ?? "RUB"))")
                        .foregroundStyle(.white)
                }
                GeometryReader { geomtry in
                    VStack {
                        HStack {
                            Text("Figi")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 8)
                                .foregroundColor(.white)
                            Text("Баланс")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 8)
                                .foregroundColor(.white)
                            Text("Цена")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 8)
                                .foregroundColor(.white)
                            Text("Средняя")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 8)
                                .foregroundColor(.white)
                            Text("Стоимость")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 5.5)
                                .foregroundColor(.white)
                            Text("Доход")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 7)
                                .foregroundColor(.white)
                            Text("Доход, %")
                                .font(.callout)
                                .frame(width: geomtry.size.width / 9)
                                .foregroundColor(.white)
                        }
                        .background(Color(.panel))
                        .cornerRadius(6)
                        ScrollView {
                            ForEach(dataAPI.portfolio?.positions ?? [], id: \.positionUid) { position in
                                if position.figi != "RUB000UTSTOM" {
                                    Button {
                                        sendNewTicker(position: position)
                                    } label: {
                                        HStack {
                                            Text(position.figi ?? "Non")
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 8)
                                                .foregroundColor(.white)
                                            Text(position.quantity?.value?.formatted() ?? "0")
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 8)
                                                .foregroundColor(.white)
                                            Text(position.currentPrice?.value?.formatted() ?? "0")
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 8)
                                                .foregroundColor(.white)
                                            Text(position.averagePositionPrice?.value?.formatted() ?? "0")
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 8)
                                                .foregroundColor(.white)
                                            Text(position.cost.formatted(defaultStyle))
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 5.5)
                                                .foregroundColor(.white)
                                            Text(position.expectedYield?.value?.formatted() ?? "0")
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 7)
                                                .foregroundColor(position.expectedYield?.value?.sign == .minus ? .red : .green)
                                            Text("\(position.incomePercent.formatted(defaultStyle))%")
                                                .font(.subheadline)
                                                .frame(width: geomtry.size.width / 9)
                                                .foregroundColor(position.expectedYield?.value?.sign == .minus ? .red : .green)
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .background(Color(.background))
    }
}

extension PortfolioView {
    private func sendNewTicker(position: Position) {
        Task {
            do {
                try await dataAPI.getFindInstrument(user: userView.user, query: position.figi ?? "BBG006L8G4H1")
                if userView.user.figi != dataAPI.findInstrument?.instruments?[0]?.figi {
                    marketData.stopStream()
                }
                if let instrument = dataAPI.findInstrument?.instruments?[0] {
                    userView.changeTicker(figi: instrument.figi ?? "BBG006L8G4H1", instrumentUid: instrument.uid ?? "10e17a87-3bce-4a1f-9dfc-720396f98a3c", name: instrument.name ?? "Яндекс", ticker: instrument.ticker ?? "YNDX")
                }
                dismiss()
            } catch {
            }
        }
    }
}
