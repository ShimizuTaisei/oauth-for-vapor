//
//  AuthorizationCodes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import VaporOAuth
import Crypto

@AuthorizationCodeModel
public final class AuthorizationCodes: AuthorizationCode {
    public static var schema: String = "oauth_authorization_codes"
    
    public typealias User = Users
    public typealias AccessTokenType = AccessTokens
    public typealias RefreshTokenType = RefreshTokens
    
    public static func forDelete(on database: Database) async throws -> [AuthorizationCodes] {
        let revokedAuthCodes = try await AuthorizationCodes.query(on: database).group(.or) { group in
            group.filter(\.$isRevoked == true).filter(\.$expired < Date())
        }.withDeleted().all()
        return revokedAuthCodes
    }
}
