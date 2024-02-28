//
//  UserModel.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI

@Observable
class User: Codable {
    var token = "" {didSet {saveData()}}
    var id = "" {didSet {saveData()}}
    var instrumentUid = "10e17a87-3bce-4a1f-9dfc-720396f98a3c"
    var figi = "BBG006L8G4H1"
    var ticker = "YNDX" 
    var name = "Яндекс" {didSet {saveData()}}
    
    private let storageKey = "Data"
    
    init() {
        loadData()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._token = try container.decode(String.self, forKey: ._token)
        self._id = try container.decode(String.self, forKey: ._id)
        self._instrumentUid = try container.decode(String.self, forKey: ._instrumentUid)
        self._figi = try container.decode(String.self, forKey: ._figi)
        self._ticker = try container.decode(String.self, forKey: ._ticker)
        self._name = try container.decode(String.self, forKey: ._name)
    }
    
    enum CodingKeys: CodingKey {
        case _token
        case _id
        case _instrumentUid
        case _figi
        case _ticker
        case _name
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._token, forKey: ._token)
        try container.encode(self._id, forKey: ._id)
        try container.encode(self._instrumentUid, forKey: ._instrumentUid)
        try container.encode(self._figi, forKey: ._figi)
        try container.encode(self._ticker, forKey: ._ticker)
        try container.encode(self._name, forKey: ._name)
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(User.self, from: data) else { return }
        token = decoded.token
        id = decoded.id
        instrumentUid = decoded.instrumentUid
        figi = decoded.figi
        ticker = decoded.ticker
        name = decoded.name
    }
    
    private func saveData() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

