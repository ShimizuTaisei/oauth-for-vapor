//
//  OAuthAuthenticator.swift
//
//  
//  Created by Shimizu Taisei on 2024/03/10.
//  


import Foundation
import Vapor
import Fluent

public struct OAuthAuthenticator<AccessTokenType: AccessToken>: AsyncBearerAuthenticator {
    public init() {}
    
    public func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
        guard let tokenData = bearer.token.base64URLDecoded(),
              let tokenWithID = String(data: tokenData, encoding: .utf8) else {
            throw Abort(.badRequest)
        }
        let tokenAndID = tokenWithID.components(separatedBy: ":")
        guard let tokenID = UUID(uuidString: tokenAndID[0]) else {
            throw Abort(.badRequest)
        }
        let tokenBody = tokenAndID[1]
        
        guard let accessToken = try await AccessTokenType.findByID(id: tokenID, on: request.db) else {
            throw Abort(.unauthorized)
        }
        
        if try Bcrypt.verify(tokenBody, created: accessToken.accessToken) {
            request.auth.login(accessToken.user)
        }
    }
}
