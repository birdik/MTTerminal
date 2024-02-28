//
//  Requests.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

protocol Requests: Codable, Hashable {
    var headURL: String { get }
}

struct Request {
    let data: any Requests
    let token: String
    private let httpMethod = "POST"
    var request: URLRequest {
        let url = URL(string: "https://invest-public-api.tinkoff.ru/rest/tinkoff.public.invest.api.contract.v1.\(data.headURL)")!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
