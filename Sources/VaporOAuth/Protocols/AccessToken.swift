//
//  AccessToken.swift
//
//
//  Created by Shimizu Taisei on 2024/01/03.
//


import Foundation
import Fluent

/// A protocol that defines the members for table which stores access tokens.
public protocol AccessToken: Model where IDValue == UUID {
    /// The type of user table.
    associatedtype User: Model, ModelAuthenticatable
    /// The type of access token scope table which you defined. It should conform to ``AccessTokenScope``.
    associatedtype AccessTokenScopeType: AccessTokenScope
    
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var accessToken: String { get set }
    var user: User { get set }
    var client: OAuthClients { get set }
    var scopes: [OAuthScopes] { get set }
    
    ///
    /// - Parameters:
    ///   - expired: The date when the token will expire.
    ///   - accessToken: The body of access token.
    ///   - userID: The ID of user who was related to this token.
    ///   - clientID: The ID of client which was related to this token.
    init(expired: Date, accessToken: String, userID: User.IDValue, clientID: UUID) throws
    
    /// Set list of scopes to the access token.
    /// - Parameters:
    ///   - scopes: The list of scopes which should be attached to the token.
    ///   - database: The database.
    func setScope(_ scopes: [OAuthScopes], on database: Database) async throws
    
    /// Get list of access token for database cleanup.
    /// - Parameter database: The database object.
    /// - Returns: The list of access token which is expected to delete.
    static func forDelete(on database: Database) async throws -> [Self]
    
    /// Find instance of class which conforms to ``AccessToken`` by given id with eager loading.
    /// - Parameters:
    ///   - id: The ID of token to search database.
    ///   - database: Database.
    /// - Returns: The query result.
    static func findByID(id: UUID, on database: Database) async throws -> Self?
}
