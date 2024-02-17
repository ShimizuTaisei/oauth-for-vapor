//
//  AccessTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import Vapor
import VaporOAuth
import Crypto

@AccessTokenModel
public final class AccessTokens: AccessToken {
    public static var schema: String = "oauth_access_tokens"
    public typealias User = Users
    public typealias AccessTokenScopeType = AccessTokenScopes
    
    public static func forDelete(on database: Database) async throws -> [AccessTokens] {
        let revokedAccessTokens = try await AccessTokens.query(on: database).group(.or) { group in
            group.filter(\.$isRevoked == true).filter(\.$expired < Date())
        }.withDeleted().all()
        return revokedAccessTokens
    }
}

@AccessTokenAuthenticator
struct UserAuthenticator: TokenAuthenticator {
    typealias AccessTokenType = AccessTokens
}
