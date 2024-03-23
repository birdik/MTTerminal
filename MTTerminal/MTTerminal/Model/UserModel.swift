//
//  UserModel.swift
//  MTTerminal
//
//  Created by Vladislav Kiyko on 23.03.2024.
//

import SwiftUI

struct User: Codable {
    var token: String
    var id: String
    var instrumentUid: String
    var figi: String
    var ticker: String
    var name: String
    
    init() {
        self.token = ""
        self.id = ""
        self.instrumentUid = "10e17a87-3bce-4a1f-9dfc-720396f98a3c"
        self.figi = "BBG006L8G4H1"
        self.ticker = "YNDX"
        self.name = "Яндекс"
    }
    
    
}
