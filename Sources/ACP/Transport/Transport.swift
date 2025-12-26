//
//  Transport.swift
//  swift-acp
//
//  Unified transport interface for ACP communication.
//

import Foundation

/// Transport type for ACP communication
public enum TransportType {
    case process(command: String, arguments: [String], workingDirectory: URL?)
    case http(url: URL)
}

/// Unified transport interface for ACP communication
public final class ACPTransport: @unchecked Sendable {

    // MARK: - Properties

    private let type: TransportType
    private var processTransport: ProcessTransport?
    private var httpTransport: HTTPTransport?

    public var isConnected: Bool {
        get async {
            switch type {
            case .process:
                guard let pt = processTransport else { return false }
                return await pt.isConnected
            case .http:
                return true // HTTP is always "connected" once initialized
            }
        }
    }

    // MARK: - Initialization

    /// Create a transport for the given type
    public init(type: TransportType) {
        self.type = type

        switch type {
        case .process(let command, let arguments, let workingDirectory):
            self.processTransport = ProcessTransport(
                command: command,
                arguments: arguments,
                workingDirectory: workingDirectory
            )
        case .http(let url):
            self.httpTransport = HTTPTransport(baseURL: url)
        }
    }

    /// Create a process-based transport for a local agent
    public static func process(command: String, arguments: [String] = [], workingDirectory: URL? = nil) -> ACPTransport {
        ACPTransport(type: .process(command: command, arguments: arguments, workingDirectory: workingDirectory))
    }

    /// Create an HTTP transport for a remote server
    public static func http(url: URL) -> ACPTransport {
        ACPTransport(type: .http(url: url))
    }

    /// Create an HTTP transport from a string
    public static func http(urlString: String) -> ACPTransport {
        ACPTransport(type: .http(url: URL(string: urlString)!))
    }

    // MARK: - Connection

    /// Set the handler for incoming messages
    public func setMessageHandler(_ handler: @escaping @Sendable (IncomingMessage) async -> Void) {
        switch type {
        case .process:
            guard let pt = processTransport else { return }
            Task {
                await pt.setMessageHandler(handler)
            }
        case .http:
            guard let ht = httpTransport else { return }
            Task {
                await ht.setMessageHandler(handler)
            }
        }
    }

    /// Connect to the transport
    public func connect() async throws {
        switch type {
        case .process:
            guard let pt = processTransport else { throw TransportError.notConnected }
            try await pt.connect()
        case .http:
            guard let ht = httpTransport else { throw TransportError.notConnected }
            try await ht.connect()
        }
    }

    /// Disconnect from the transport
    public func disconnect() {
        switch type {
        case .process:
            guard let pt = processTransport else { return }
            Task {
                await pt.disconnect()
            }
        case .http:
            guard let ht = httpTransport else { return }
            Task {
                await ht.disconnect()
            }
        }
    }

    // MARK: - Messaging

    /// Get the next request ID
    public func nextRequestID() async -> RequestID {
        switch type {
        case .process:
            guard let pt = processTransport else { return .string("0") }
            return await pt.nextRequestID()
        case .http:
            guard let ht = httpTransport else { return .string("0") }
            return await ht.nextRequestID()
        }
    }

    /// Send a request and wait for response
    public func sendRequest<Params: Encodable & Sendable, Result: Decodable & Sendable>(
        method: String,
        params: Params?
    ) async throws -> Result {
        switch type {
        case .process:
            guard let pt = processTransport else { throw TransportError.notConnected }
            return try await pt.sendRequest(method: method, params: params)
        case .http:
            guard let ht = httpTransport else { throw TransportError.notConnected }
            return try await ht.sendRequest(method: method, params: params)
        }
    }

    /// Send a notification
    public func sendNotification<Params: Encodable & Sendable>(
        method: String,
        params: Params?
    ) async throws {
        switch type {
        case .process:
            guard let pt = processTransport else { throw TransportError.notConnected }
            try await pt.sendNotification(method: method, params: params)
        case .http:
            guard let ht = httpTransport else { throw TransportError.notConnected }
            try await ht.sendNotification(method: method, params: params)
        }
    }

    /// Send a response
    public func sendResponse<Result: Encodable & Sendable>(
        id: RequestID,
        result: Result
    ) async throws {
        switch type {
        case .process:
            guard let pt = processTransport else { throw TransportError.notConnected }
            try await pt.sendResponse(id: id, result: result)
        case .http:
            guard let ht = httpTransport else { throw TransportError.notConnected }
            try await ht.sendResponse(id: id, result: result)
        }
    }

    /// Send an error response
    public func sendErrorResponse(
        id: RequestID,
        code: Int,
        message: String
    ) async throws {
        switch type {
        case .process:
            guard let pt = processTransport else { throw TransportError.notConnected }
            try await pt.sendErrorResponse(id: id, code: code, message: message)
        case .http:
            guard let ht = httpTransport else { throw TransportError.notConnected }
            try await ht.sendErrorResponse(id: id, code: code, message: message)
        }
    }
}
