//
//  APIManager.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 07.11.2023.
//

import SwiftUI

final class APIManager {
    func answer<T:Codable>(request: Request) async throws -> T {
        let data = try JSONEncoder().encode(request.data)
        let (answer, _) = try await URLSession.shared.upload(for: request.request, from: data)
        return try JSONDecoder().decode(T.self, from: answer)
    }
    
    func dateFromWebtoApp(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = .current
        return  dateFormatter.string(from: date!)
    }    
    
}

