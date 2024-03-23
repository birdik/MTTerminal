//
//  Head.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct Head: View {
    @Bindable var userView: UserView
    @Bindable var dataAPI: GetDataAPI
    @Bindable var marketData: MarketDataStream
    @State private var showingPortfolio = false
    @Binding var showingAlert: Bool
    
    let timer = Timer.publish(every: 1.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                showingPortfolio.toggle()
            } label: {
                Text("Баланс: \(dataAPI.portfolio?.totalAmountPortfolio?.value ?? 0, format: .currency(code: dataAPI.portfolio?.totalAmountPortfolio?.currency ?? "RUB"))")
                    .font(.subheadline)
            }
            .padding(.horizontal, 5.0)
            .foregroundStyle(.white)
                
            Spacer()
            
            Button("Выход") {
                marketData.stopStream()
                userView.deleteId()
            }
            .font(.subheadline)
            .padding(.horizontal, 5.0)
            .foregroundStyle(.red)
                
        }
        .padding(2)
        .background(Color("panel"))
        .cornerRadius(10)
        .onReceive(timer) { _ in
            Task(priority: .background) {
                do {
                    try await dataAPI.getPortfolio(user: userView.user)
                } catch {
                    timer.upstream.connect().cancel()
                    showingAlert = true
                }
            }
        }
        .sheet(isPresented: $showingPortfolio) {
            PortfolioView(userView: userView, dataAPI: dataAPI, marketData: marketData)
        }
    }
}

