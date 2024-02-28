//
//  Head.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct Head: View {
    @Bindable var user: User
    @Bindable var dataAPI: GetDataAPI
    @State private var showingPortfolio = false
    @Binding var stream: SocketStream?
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
                stream?.cancel()
                user.id = ""
            }
            .font(.subheadline)
            .padding(.horizontal, 5.0)
            .foregroundStyle(.red)
                
        }
        .padding(2)
        .background(Color("panel"))
        .cornerRadius(10)
        .onReceive(timer) { _ in
            Task {
                do {
                    try await dataAPI.getPortfolio(token: user.token, id: user.id)
                } catch {
                    timer.upstream.connect().cancel()
                    showingAlert = true
                }
            }
        }
        .sheet(isPresented: $showingPortfolio) {
            PortfolioView(user: user, dataAPI: dataAPI, stream: $stream)
        }
    }
}

