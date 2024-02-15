//
//  ClientAuthenticator.swift
//
//  
//  Created by Shimizu Taisei on 2024/02/12.
//  


import Foundation
import Vapor

public struct ClientAuthenticator: AsyncBasicAuthenticator {
    public init() {}
    
    public func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        let clientID = UUID(uuidString: basic.username)
        guard let client = try await OAuthClients.find(clientID, on: request.db), let secret = client.clientSecret else { return }
        if try Bcrypt.verify(basic.password, created: secret) {
            request.auth.login(client)
        }
    }
}
