//
//  IdView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 08.11.2023.
//

import SwiftUI

struct IdView: View {
    @Bindable var userView: UserView
    @Bindable var dataAPI: GetDataAPI
    @Binding var showingAlert: Bool
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Выход") {userView.deleteToken()}
                    .foregroundStyle(.red)
            }
            .padding(.top, 5.0)
            Spacer()
            Text("Выберите счёт:")
                .foregroundStyle(.white)
            ScrollView {
                ForEach(dataAPI.accounts.accounts ?? [], id: \.id) { account in
                    if account.status == "ACCOUNT_STATUS_OPEN" {
                        Button() {
                            userView.setId(id: account.id ?? "0")
                        } label : {
                            HStack(alignment: .center) {
                                Text(account.name ?? "0")
                                    .padding([.top, .leading, .bottom], 5.0)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(" Дата открытия: \(APIManager().dateFromWebtoApp(account.openedDate!))")
                                    .padding([.top, .bottom, .trailing], 5.0)
                                    .foregroundStyle(.white)
                            }
                            .background(Color("panel"))
                            .cornerRadius(10)
                        }
                    } else {
                        Text("Нет активных счетов")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .task(getAccounts)
    }
}

extension IdView {
    @Sendable private func getAccounts() async {
        do {
            try await dataAPI.getAccounts(user: userView.user)
        } catch {
            showingAlert = true
        }
    }
}
