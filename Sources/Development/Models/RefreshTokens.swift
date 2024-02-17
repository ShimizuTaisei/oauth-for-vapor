//
//  RefreshTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import VaporOAuth
import Crypto

@RefreshTokenModel
public final class RefreshTokens: RefreshToken {
    public static var schema: String = "oauth_refresh_tokens"
    
    public typealias User = Users
    public typealias AccessTokenType = AccessTokens
    
    public static func forDelete(on database: Database) async throws -> [RefreshTokens] {
        let revokedRefreshTokens = try await RefreshTokens.query(on: database).group(.or) { group in
            group.filter(\.$isRevoked == true).filter(\.$expired < Date())
        }.withDeleted().all()
        return revokedRefreshTokens
    }
}

