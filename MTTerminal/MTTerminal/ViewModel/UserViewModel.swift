//
//  UserModel.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI

@Observable
final class UserView: Codable {
    var user = User()
    
    private let storageKey = "Data"
    
    init() {
        loadData()
    }
    
    enum CodingKeys: CodingKey {
        case _user
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._user = try container.decode(User.self, forKey: ._user)
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._user, forKey: ._user)
    }
}


extension UserView {
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(UserView.self, from: data) else { return }
        user = decoded.user
    }
    
    private func saveData() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

extension UserView {
    func deleteId() {
        user.id = ""
        saveData()
    }
    
    func setId(id: String) {
        user.id = id
    }
    
    func deleteToken() {
        user.token = ""
        saveData()
    }
    
    func setToken(token: String) {
        user.token = token
    }
    
    func changeTicker(figi: String, instrumentUid: String, name: String, ticker: String) {
        user.figi = figi
        user.instrumentUid = instrumentUid
        user.name = name
        user.ticker = ticker
        saveData()
    }
}

