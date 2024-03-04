//
//  TokenView.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 20.02.2024.
//

import SwiftUI

struct TokenView: View {
    @Bindable var user = User()
    @State private var token = ""

    
    var body: some View {
        VStack {
            Text("Введите API Токен:")
                .foregroundStyle(.white)
            TextField("Token", text: $token)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .background(.black)
                .border(.black)
                .cornerRadius(5)
                .frame(minWidth: 0, maxWidth: 300)
            Button ("Вход") {
                user.token = token
            }
            .foregroundColor(Color.white)
            .padding(5)
            .background(.blue)
            .cornerRadius(5)
        }
    }
}


