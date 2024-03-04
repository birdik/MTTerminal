//
//   ActiveApplicationsView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.02.2024.
//

import SwiftUI

struct ActiveApplications: View {
    @Bindable var user: User
    @Bindable var dataAPI: GetDataAPI
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    @Binding var showingAlert: Bool
    @State private var showingAlertOrder = false
    
    var body: some View {
        VStack {
            Text("Активные заявки")
                .font(.footnote)
                .foregroundStyle(Color("symbol"))
            ScrollView{
                ForEach(dataAPI.orders?.orders ?? [], id: \.?.orderId) { order in
                    if user.figi == order?.figi {
                        VStack {
                            HStack {
                                if order?.direction == "ORDER_DIRECTION_BUY" {
                                    Text("Buy")
                                        .font(.footnote)
                                        .foregroundColor(.green)
                                } else {
                                    Text("Sell")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                                Spacer()
                                Text("Price: " + "\(order?.initialSecurityPrice?.value?.formatted() ?? "0")")
                                    .font(.footnote)
                                    .foregroundColor(Color.white)
                                Spacer()
                                Text("Vol: " + "\(order?.lotsRequested ?? "0")")
                                    .font(.footnote)
                                    .foregroundColor(Color.white)
                            }
                            Button("Отмена") {
                                Task {
                                    do {
                                        try await dataAPI.getCancelOrder(token: user.token, id: user.id, orderId: order?.orderId ?? "0")
                                    } catch {
                                        showingAlertOrder = true
                                    }
                                }
                            }
                            .font(.subheadline)
                            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(Color.gray)
                            .foregroundColor(Color.white)
                            .cornerRadius(5)
                        }
                        .padding(.horizontal, 5.0)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            Task {
                do {
                    try await dataAPI.getOrders(token: user.token, id: user.id)
                } catch {
                    timer.upstream.connect().cancel()
                    showingAlert = true
                }
            }
        }
        .alert("Ошибка отмены заявки", isPresented: $showingAlertOrder) {
            Button("ОК", role: .cancel) {}
        }
    }
}

