//
//  WebSocet.swift
//  MSTerminal
//
//  Created by Vladislav Kiyko on 06.02.2024.
//

import SwiftUI


final class SocketStream: AsyncSequence {
    typealias WebSocketStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>
    typealias AsyncIterator = WebSocketStream.Iterator
    typealias Element = URLSessionWebSocketTask.Message

    private var continuation: WebSocketStream.Continuation?
    private var webSocketTask: URLSessionWebSocketTask?

    private lazy var stream: WebSocketStream = {
        return WebSocketStream { continuation in
            self.continuation = continuation
            waitForNextValue()
        }
    }()

    init() {}
    
    func connect(token: String, url: URL) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
    }
    
    private func waitForNextValue() {
        guard webSocketTask?.closeCode == .invalid else {
            continuation?.finish()
            return
        }

        webSocketTask?.receive(completionHandler: { [weak self] result in
            guard let continuation = self?.continuation else {
                return
            }

            do {
                let message = try result.get()
                continuation.yield(message)
                self?.waitForNextValue()
            } catch {
                continuation.finish(throwing: error)
            }
        })
    }
    
    func sendMessage(_ data: Codable) async throws {
        let data = try JSONEncoder().encode(data)
        try await webSocketTask?.send(.data(data))
    }

    deinit {
        continuation?.finish()
    }

    func makeAsyncIterator() -> AsyncIterator {
        return stream.makeAsyncIterator()
    }

    func cancel()  {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        continuation?.finish()
    }
}

