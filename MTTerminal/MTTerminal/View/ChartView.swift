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
    @Bindable var userView: UserView
    @State private var interval: CandleInterval = .fiveMin
    @State private var showingAlert = false
    @State private var position: String?
    @State private var candlePosition: Candle?
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        VStack {
            HStack {
                Button("Назад") {dataAPI.candles = nil
                    dismiss()}.font(.subheadline)
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
            if let candlePosition {
                HStack {
                    Text("ОТКР: \(candlePosition.close?.value?.formatted() ?? "0")")
                        .foregroundStyle(candlePosition.color ? .red : .green)
                        .font(.caption)
                    Text("МАКС: \(candlePosition.high?.value?.formatted() ?? "0")")
                        .foregroundStyle(candlePosition.color ? .red : .green)
                        .font(.caption)
                    Text("МИН: \(candlePosition.low?.value?.formatted() ?? "0")")
                        .foregroundStyle(candlePosition.color ? .red : .green)
                        .font(.caption)
                    Text("ЗАКР: \(candlePosition.close?.value?.formatted() ?? "0")")
                        .foregroundStyle(candlePosition.color ? .red : .green)
                        .font(.caption)
                    Text("(\(candlePosition.percent)%)")
                        .foregroundStyle(candlePosition.color ? .red : .green)
                        .font(.caption)
                    Text("VOL: \(candlePosition.volume ?? "0")")
                        .foregroundStyle(candlePosition.color ? .red : .green)
                        .font(.caption)
                    Text(position ?? "")
                        .foregroundStyle(.white)
                        .font(.caption)
                    Spacer()
                }
            }
            if let data = dataAPI.candles?.candles {
                CandlesChart(dataAPI: dataAPI, position: $position, data: data)
                .chartYAxis {
                    AxisMarks() { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.4))
                        AxisTick()
                            .foregroundStyle(.white.opacity(0.4))
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: dataAPI.candles?.axisMarks ?? []) { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.4))
                        AxisTick()
                            .foregroundStyle(.white.opacity(0.4))
                        AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .chartYScale(domain: [(dataAPI.candles?.minLow ?? 0),(dataAPI.candles?.maxHigh ?? 0)], range: .plotDimension(startPadding: 15, endPadding: 15))
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: 50)
                .chartScrollPosition(initialX: (dataAPI.candles?.initialXScroll ?? "0"))
                .chartXSelection(value: $position)
                .onChange(of: position) {
                    if let position {
                        let candleFilter = dataAPI.candles?.candles?.filter({ $0.timeToData.formatted() == position })
                        candlePosition = candleFilter?[0]
                    } else { candlePosition = nil}
                }
            }
            else {
                Spacer()
                ProgressView()
                    .tint(.white)
                Spacer()
            }
        }
        .background(Color("background"))
        .alert("Ошибка получения данных графика", isPresented: $showingAlert) {
            Button("ОК", role: .cancel) {dismiss()}
        }
        .task(id: interval, priority: .high) {
            do {
                dataAPI.candles = nil
                try await dataAPI.getCandles(user: userView.user, interval: interval)
            } catch {
                  showingAlert = true
            }
        }
    }
}



struct CandlesChart: View {
    @Bindable var dataAPI: GetDataAPI
    @Binding var position: String?
    var data: [Candle]
    
    var body: some View {
        Chart(data, id: \.time) {
            if $0.open?.value == $0.close?.value {
                RectangleMark(
                    x: .value("Время", $0.timeToData.formatted()),
                    y: .value("Цена", $0.close?.value ?? 0),
                    width: 9,
                    height: 2
                )
                .foregroundStyle($0.color ? .red : .green)
            } else {
                RectangleMark(
                    x: .value("Время", $0.timeToData.formatted()),
                    yStart: .value("Цена открытия", $0.open?.value ?? 0),
                    yEnd: .value("Цена закрытия", $0.close?.value ?? 0),
                    width: 9
                )
                .foregroundStyle($0.color ? .red : .green)
            }
            RectangleMark(
                x: .value("Время", $0.timeToData.formatted()),
                yStart: .value("Минимальная цена", $0.low?.value ?? 0),
                yEnd: .value("Максимльная цена", $0.high?.value ?? 0),
                width: 1
            )
            .foregroundStyle($0.color ? .red : .green)
            BarMark(x: .value("date", $0.timeToData.formatted()), yStart: .value("volumem", dataAPI.candles?.minLow ?? 0), yEnd: .value("volume", $0.volumeMaxY), width: 9)
                .foregroundStyle($0.color ? .red.opacity(0.6) : .green.opacity(0.6))
            if data.last?.timeToData == $0.timeToData {
                RuleMark(y: .value("Цена закрытия последней свечи", $0.close?.value ?? 0))
                    .foregroundStyle(.white.opacity(0.3))
                    .annotation(alignment: .bottomTrailing) {
                        Text(data.last?.close?.value?.formatted() ?? "0")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
            }
        }
    }
}

