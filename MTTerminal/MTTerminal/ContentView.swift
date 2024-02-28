//
//  ContentView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable private var user = User()
    @Bindable private var dataAPI = GetDataAPI()
    @Bindable private var marketData = MarketDataStream()
    @Bindable private var network = NetworkMonitor()
    @State private var launchingApplication = 0
    @State private var launchingApplicationBackground = 0
    @State private var price: Decimal?
    @State private var stream: SocketStream?
    @State private var showingAlert = false

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            if user.token.isEmpty {
                TokenView(user: user)
            } else {
                if user.id.isEmpty {
                    IdView(user: user, dataAPI: dataAPI, showingAlert: $showingAlert)
                } else {
                    VStack {
                        Head(user: user, dataAPI: dataAPI, stream: $stream, showingAlert: $showingAlert)
                        HStack {
                            VStack {
                                GeometryReader { geometry in
                                    VStack{
                                        Application(price: $price, stream: $stream, marketData: marketData, dataAPI: dataAPI, user: user)
                                            .frame(width: geometry.size.width, height: geometry.size.height*2/3)
                                            .background(Color("panel"))
                                            .cornerRadius(10)
                                        ActiveApplications(user: user, dataAPI: dataAPI, showingAlert: $showingAlert)
                                            .frame(width: geometry.size.width)
                                            .background(Color("panel"))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            Glass(marketData: marketData, dataAPI: dataAPI, user: user, price: $price)
                            Tape(marketData: marketData)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .task(id: user.figi) {
                            do {
                                try await startWebSocet()
                            } catch {
                                showingAlert = true
                            }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: scenePhase, initial: false) { oldPhase, newPhase in
            if newPhase == .active {
                if launchingApplication == 0 {
                    launchingApplication += 1
                } else {
                    if launchingApplicationBackground != 0 {
                        launchingApplicationBackground = 0
                        Task {
                            do {
                                try await startWebSocet()
                            } catch {
                                showingAlert = true
                            }
                        }
                    }
                }
            } else if newPhase == .background {
                launchingApplicationBackground = 1
                stream?.cancel()
            }
        }
        .alert("Ошибка работы API", isPresented: $showingAlert) {
            Button("OK") {exit(0)}
        } message: {
            Text("Перезайдите в приложение или подождите 5 минут")
        }
        .onChange(of: network.isConnected) {
            showingAlert = true
        }
    }
    
    private func startWebSocet() async  throws {
        marketData.trades = []
        marketData.orderbook = nil
        marketData.lastPrice = nil
        stream = SocketStream()
        stream?.connect(token: user.token, url: marketData.url)
        try await stream?.sendMessage(marketData.sendTrades(instrumentId: user.instrumentUid, figi: user.figi, action: .subscribe))
        try await stream?.sendMessage(marketData.sendOrderBook(instrumentId: user.instrumentUid, figi: user.figi, depth: 20, action: .subscribe))
        try await stream?.sendMessage(marketData.sendLastPrice(instrumentId: user.instrumentUid, figi: user.figi, action: .subscribe))
        for try await message in stream! {
            switch message {
            case let .string(string):
                let data = try JSONDecoder().decode(MarketDataService.self, from: Data(string.utf8))
                marketData.receivedMarketData(data: data)
            case .data(_):
                break
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
