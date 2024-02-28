//
//  ChartView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 16.02.2024.
//

import SwiftUI
import Charts

struct ChartView: View {
    @Bindable var dataAPI: GetDataAPI
    @Bindable var user: User
    @State private var interval: CandleInterval = .fiveMin
    @State private var showingAlert = false
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            HStack {
                Button("Назад") {dismiss()}.font(.subheadline)
                //Button("1m") { interval = .oneMin}.font(.subheadline)
                Button("5m") { interval = .fiveMin}.font(.subheadline)
                Button("15m") { interval = .fifteenMin}.font(.subheadline)
                Button("30m") { interval = .thirtyMin}.font(.subheadline)
                Button("1h") { interval = .hour}.font(.subheadline)
                Button("4h") { interval = .fourHour}.font(.subheadline)
                Button("1d") { interval = .day}.font(.subheadline)
                Button("1w") { interval = .week}.font(.subheadline)
                Button("1mo") { interval = .month}.font(.subheadline)
                Spacer()
            }
            .padding(.top, 5.0)
            Chart {
                ForEach(dataAPI.candles?.candles ?? [] , id: \.time) { candle in
                    if candle.open?.value == candle.close?.value {
                        RectangleMark(
                            x: .value("Время", candle.timeToData),
                            y: .value("Цена", candle.close?.value ?? 0),
                            width: 9,
                            height: 1
                        )
                        .foregroundStyle(subtraction(candle.open?.value ?? 0, candle.close?.value ?? 0) > 0 ? .red : .green)
                    } else {
                        RectangleMark(
                            x: .value("Время", candle.timeToData),
                            yStart: .value("Цена открытия", candle.open?.value ?? 0),
                            yEnd: .value("Цена закрытия", candle.close?.value ?? 0),
                            width: 9
                        )
                        .foregroundStyle(subtraction(candle.open?.value ?? 0, candle.close?.value ?? 0) > 0 ? .red : .green)
                    }
                    RectangleMark(
                        x: .value("Время", candle.timeToData),
                        yStart: .value("Минимальная цена", candle.low?.value ?? 0),
                        yEnd: .value("Максимльная цена", candle.high?.value ?? 0),
                        width: 1
                    )
                    .foregroundStyle(subtraction(candle.open?.value ?? 0, candle.close?.value ?? 0) > 0 ? .red : .green)
                    if dataAPI.candles?.candles?.last?.timeToData == candle.timeToData {
                        RuleMark(y: .value("Цена закрытия последней свечи", candle.close?.value ?? 0))
                            .foregroundStyle(.white.opacity(0.3))
                            .annotation(alignment: .bottomTrailing) {
                                Text(candle.close?.value?.formatted() ?? "0")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                    }
                }
            }
            .chartYAxis {
                AxisMarks() { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .chartXAxis {
                AxisMarks() { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .chartYScale(domain: (dataAPI.candles?.minLow ?? 0)...(dataAPI.candles?.maxHigh ?? 0))
            .chartScrollableAxes(.horizontal)
            .chartScrollPosition(initialX: dataAPI.candles?.candles?.last?.timeToData ?? Date())
            .chartXVisibleDomain(length: interval.chartLength)
        }
        .background(Color("background"))
        .alert("Ошибка получения данных графика", isPresented: $showingAlert) {
            Button("ОК", role: .cancel) {dismiss()}
        }
        .task(id: interval) {
            do {
                dataAPI.candles = nil
                try await dataAPI.getCandles(token: user.token, instrumentId: user.instrumentUid, figi: user.figi, interval: interval)
            } catch {
                  showingAlert = true
            }
        }
    }
    
    private func subtraction (_ a: Decimal, _ b: Decimal) -> Decimal {
        a - b
    }
}

