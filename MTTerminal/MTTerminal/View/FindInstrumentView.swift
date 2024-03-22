//
//  FindInstrumentView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 13.02.2024.
//

import SwiftUI

struct FindInstrumentView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var userView: UserView
    @Bindable var marketData: MarketDataStream
    @Bindable var dataAPI: GetDataAPI
    @State private var query: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Button {
                    dismiss()
                } label: {
                    Label("Назад", systemImage: "chevron.backward")
                        .padding(.top, 5.0)
                }
                Spacer()
            }
            .background(Color("background"))
            HStack {
                Spacer()
                VStack {
                    Text("Введите название инструмента:")
                        .font(.subheadline)
                        .padding(.top, 5.0)
                        .foregroundStyle(.white)
                    TextField("Инструмент", text: $query)
                        .font(.title3)
                        .submitLabel(.done)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .background(.black)
                        .border(.black)
                        .cornerRadius(5)
                    ScrollView {
                        ForEach(dataAPI.findInstrument?.instruments ?? [], id: \.?.figi) { instrument in
                            Button {
                                if userView.user.figi != instrument?.figi {
                                    marketData.stopStream()
                                }
                                userView.changeTicker(figi: instrument?.figi ?? "BBG006L8G4H1", instrumentUid: instrument?.uid ?? "10e17a87-3bce-4a1f-9dfc-720396f98a3c", name: instrument?.name ?? "Яндекс", ticker: instrument?.ticker ?? "YNDX")
                                dismiss()
                            } label: {
                                HStack {
                                    Text(instrument?.name ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text(instrument?.ticker ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\n")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Text(instrument?.instrumentKinds ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    
                                }
                                .padding(.horizontal, 5.0)
                                .background(Color("panel"))
                                .cornerRadius(5)
                            }
                        }
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width/2)
                Spacer()
            }
            .padding(.top, 3)
            .task(id: query, findInstrument)
        }
        .background(Color("background"))
    }
}

extension FindInstrumentView {
   @Sendable private func findInstrument() async {
        if query.count > 2 {
            do {
                try await dataAPI.getFindInstrument(user: userView.user, query: query)
            } catch {
            }
        }
    }
}
