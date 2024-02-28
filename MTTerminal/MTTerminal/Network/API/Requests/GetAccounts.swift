//
//  GetId.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

struct  Accounts: Codable {
    let accounts: [Account]?
    
    struct Account: Codable {
        let id: String?
        let type: String?
        let name: String?
        let status: String?
        let openedDate: String?
        let closedDate: String?
        let accessLevel: String?
    }

}

struct GetEmptyData: Requests {
    var headURL = "UsersService/GetAccounts"
}
