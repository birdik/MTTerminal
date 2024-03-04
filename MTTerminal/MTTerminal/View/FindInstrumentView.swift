//
//  FindInstrumentView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 13.02.2024.
//

import SwiftUI

struct FindInstrumentView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var user: User
    @Bindable var dataAPI: GetDataAPI
    @Binding var stream: SocketStream?
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
                                if user.figi != instrument?.figi {
                                    stream?.cancel()
                                }
                                user.figi = instrument?.figi ?? "BBG006L8G4H1"
                                user.instrumentUid = instrument?.uid ?? "10e17a87-3bce-4a1f-9dfc-720396f98a3c"
                                user.ticker = instrument?.ticker ?? "YNDX"
                                user.name = instrument?.name ?? "Яндекс"
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
            .onChange(of: query) {
                if query.count > 2 {
                    Task {
                        do {
                            try await dataAPI.getFindInstrument(token: user.token, query: query)
                        } catch {
                        }
                    }
                }
            }
        }
        .background(Color("background"))
    }
}

