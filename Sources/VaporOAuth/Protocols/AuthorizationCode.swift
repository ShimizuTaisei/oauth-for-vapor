//
//  AuthorizationCode.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent
import Vapor

/// A protocol that defines menbers for table which stores authorization codes.
public protocol AuthorizationCode: Model {
    /// The type of user table.
    associatedtype User: Model, Authenticatable
    
    /// The type of access token table. It should be conform to ``AccessToken``.
    associatedtype AccessTokenType: AccessToken
    
    /// The type of refresh token table. It should be conform to ``RefreshToken``.
    associatedtype RefreshTokenType: RefreshToken
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var isUsed: Bool { get set }
    var code: String { get set }
    var redirectURI: String { get set }
    var codeChallenge: String { get set }
    var codeChallengeMethod: String { get set }
    var client: OAuthClients { get set }
    var user: User { get set }
    var accessToken: AccessTokenType? { get set }
    var refreshToken: RefreshTokenType? { get set }
    var scopes: [OAuthScopes] { get set }
    
    ///
    /// - Parameters:
    ///   - expired: The date when the code will expire.
    ///   - code: The body of authorization code.
    ///   - redirectURI: The redirect uri which registerd to clients table.
    ///   - clientID: The ID of client which is related to this record.
    ///   - userID: The ID of user which is related to this table.
    init(expired: Date, code: String, redirectURI: String, codeChallenge: String, codeChallengeMethod: String,
         clientID: UUID, userID: User.IDValue)
    
    /// Set list of scopes to this record.
    /// - Parameters:
    ///   - scopes: The list of scopes which is related to this record.
    ///   - database: The database object.
    func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws
    
    
    /// Search instance of class which conforms to ``AuthorizationCode`` by given code and return it.
    /// - Parameters:
    ///   - database: The database object.
    ///   - code: The authorization code which is used for query database. Mostly, it is contained in access token request.
    /// - Returns: The query result that is instance of class which conforms to ``AuthorizationCode``.
    static func queryByAuthCode(on database: Database, code: String) async throws -> Self?
    
    /// Eager load access-token and refresh-token which is related to this record.
    /// - Parameter database: The database object.
    func loadTokens(on database: Database) async throws
    func setTokens(accessTokenID: UUID, refreshTokenID: UUID)
}
