//
//  RefreshToken.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

/// A protocol that defines members for table which stores refresh tokens.
public protocol RefreshToken: Model where IDValue == UUID {
    /// The type of user which is related to refresh token.
    associatedtype User: Model
    
    associatedtype RefreshTokenScopeType: RefreshTokenScope
    
    /// The type of access token which is refered from this table.
    associatedtype AccessTokenType: AccessToken
    
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var refreshToken: String { get set }
    var accessToken: AccessTokenType { get set }
    var user: User { get set }
    var client: OAuthClients { get set }
    var scopes: [OAuthScopes] { get set }
    
    ///
    /// - Parameters:
    ///   - expired: Tha date when the refresh token will be expired.
    ///   - refreshToken: The body of refresh token.
    ///   - accessTokenID: The ID of access token which refered from this record. Mostly the access token is created in same time with refresh token.
    ///   - userID: The ID of user who was related to this record.
    ///   - clientID: The ID of client which was related to this record.
    init(expired: Date, refreshToken: String, accessTokenID: UUID, userID: User.IDValue, clientID: UUID) throws
    
    
    /// Set list of scopes to this record.
    /// - Parameters:
    ///   - scopes: The list of scopes which should be attached to this record.
    ///   - database: The database object.
    func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws
    
    
    /// Search instance of class which conforms to ``RefreshToken`` and return it.
    /// - Parameters:
    ///   - refreshToken: The refresh token which is used to query database. Mostly, it is contained in token refreshing request.
    ///   - database: The database objects.
    /// - Returns: The query result that is instance of class which conforms to ``RefreshToken``.
    static func queryRefreshToken(_ refreshToken: String, on database: Database) async throws -> Self?
    
    /// Get list of refresh token for database cleanup.
    /// - Parameter database: The database object.
    /// - Returns: The list of instance of token which is expected to delete.
    static func forDelete(on database: Database) async throws -> [Self]
    
    /// Search refresh token on database by given ID.
    /// - Parameters:
    ///   - id: The id of refresh token to query.
    ///   - database: Database.
    /// - Returns: The result of query.
    static func findByID(id: UUID, on database: Database) async throws -> Self?
}
