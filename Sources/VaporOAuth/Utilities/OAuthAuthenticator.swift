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
            throw TokenAuthError(status: .badRequest, error: .invalidToken, error_description: "Failed to parse the token.")
        }
        let tokenAndID = tokenWithID.components(separatedBy: ":")
        guard let tokenID = UUID(uuidString: tokenAndID[0]) else {
            throw TokenAuthError(status: .badRequest, error: .invalidToken, error_description: "Failed to parse the token.")
        }
        let tokenBody = tokenAndID[1]
        
        guard let _ = try await AccessTokenType.findByID(id: tokenID, on: request.db, withDeleted: true) else {
            throw TokenAuthError(status: .unauthorized, error: .invalidToken, error_description: "Token not found on database.")
        }
        
        guard let accessToken = try await AccessTokenType.findByID(id: tokenID, on: request.db, withDeleted: false) else {
            throw TokenAuthError(status: .unauthorized, error: .invalidToken, error_description: "Token was already expired.")
        }
        
        if try Bcrypt.verify(tokenBody, created: accessToken.accessToken) {
            request.auth.login(accessToken.user)
        } else {
            throw TokenAuthError(status: .unauthorized, error: .invalidToken, error_description: "Invalid token.")
        }
    }
    
    private func tokenError(error: TokenAuthErrorType, errorDescription: String) throws {
        throw TokenAuthError(status: .unauthorized, error: .invalidToken, error_description: "")
    }
}

struct TokenAuthError: AbortError {
    var status: NIOHTTP1.HTTPResponseStatus
    
    var error: TokenAuthErrorType
    var error_description: String
}

enum TokenAuthErrorType: String {
    case invalidToken = "invalid_token"
}
