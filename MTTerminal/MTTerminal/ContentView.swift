//
//  ContentView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable private var userView = UserView()
    @Bindable private var dataAPI = GetDataAPI()
    @Bindable private var marketData = MarketDataStream()
    @Bindable private var network = NetworkMonitor()
    @State private var launchingApplication = 0
    @State private var launchingApplicationBackground = 0
    @State private var price: Decimal?
    @State private var showingAlert = false

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            if userView.user.token.isEmpty {
                TokenView(userView: userView)
            } else {
                if userView.user.id.isEmpty {
                    IdView(userView: userView, dataAPI: dataAPI, showingAlert: $showingAlert)
                } else {
                    VStack {
                        Head(userView: userView, dataAPI: dataAPI, marketData: marketData, showingAlert: $showingAlert)
                        HStack {
                            VStack {
                                GeometryReader { geometry in
                                    VStack{
                                        Application(price: $price, marketData: marketData, dataAPI: dataAPI, userView: userView)
                                            .frame(width: geometry.size.width, height: geometry.size.height*2/3)
                                            .background(Color("panel"))
                                            .cornerRadius(10)
                                        ActiveApplications(userView: userView, dataAPI: dataAPI, showingAlert: $showingAlert)
                                            .frame(width: geometry.size.width)
                                            .background(Color("panel"))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            Glass(marketData: marketData, dataAPI: dataAPI, userView: userView, price: $price)
                            Tape(marketData: marketData, userView: userView)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .task(id: userView.user.figi) {
                            do {
                                try await marketData.startStream(user: userView.user)
                            } catch {
                                showingAlert = true
                            }
                        }
                        .task(id: userView.user.figi) {
                            do {
                                try await dataAPI.getOrderPrice(user: userView.user, price: price?.asQuotation ?? Quotation(nano: 0, units: "1"), direction: .buy, quantity: "\(1)")
                                Trade.lot = Double("\(dataAPI.orderPrice?.initialOrderAmount?.value ?? 1)") ?? 1
                            } catch {
                            }
                        }
                    }
                    .onChange(of: scenePhase, initial: false) { oldPhase, newPhase in
                        if newPhase == .active {
                            if launchingApplication == 0 {
                                launchingApplication += 1
                            } else {
                                if launchingApplicationBackground != 0 {
                                    launchingApplicationBackground = 0
                                    Task {
                                        do {
                                            try await marketData.startStream(user: userView.user)
                                        } catch {
                                            showingAlert = true
                                        }
                                    }
                                }
                            }
                        } else if newPhase == .background {
                            launchingApplicationBackground = 1
                            marketData.stopStream()
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
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        .ignoresSafeArea(.keyboard)
    }
}

