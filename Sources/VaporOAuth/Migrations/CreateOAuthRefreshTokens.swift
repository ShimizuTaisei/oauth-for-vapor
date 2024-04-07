//
//  CreateOAuthRefreshTokens.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/27.
//  


import Foundation
import Vapor
import Fluent

/// Create table which stores refresh-token.
public struct CreateOAuthRefreshTokens: AsyncMigration {
    public var name: String
    var userTableName: String
    var userTableIdField: FieldKey
    var accessTokenTableName: String
    
    ///
    /// - Parameters:
    ///   - schema: The name of table to create.
    ///   - userTableName: The name of user table which is refered from this table.
    ///   - userTableIdField: The name of field which contain user id.
    ///   - accessTokenTableName: The name of access-token table which is refered from this table.
    @available(*, deprecated, renamed: "init", message: "Depricated in oauth-for-vapor v0.2.0\nUse init(_ configuration: OAuthMigrationConfiguration)")
    public init(_ schema: String = "oauth_refresh_tokens", userTableName: String, userTableIdField: FieldKey,
                accessTokenTableName: String = "oauth_access_tokens") {
        self.name = schema
        self.userTableName = userTableName
        self.userTableIdField = userTableIdField
        self.accessTokenTableName = accessTokenTableName
    }
    
    /// Initializer.
    /// - Parameter configurations: The configuration object which contain informations about OAuth tables.
    public init(_ configurations: OAuthMigrationConfiguration) {
        self.name = configurations.refreshTokensScheme
        self.userTableName = configurations.usersScheme
        self.userTableIdField = configurations.usersIDFieldKey
        self.accessTokenTableName = configurations.accessTokensScheme
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("expired", .string)
            .field("revoked", .bool)
            .field("refresh_token", .string, .required)
            .field("access_token_id", .uuid, .references(self.accessTokenTableName, "id", onDelete: .setNull))
            .field("user_id", .uuid, .required, .references(userTableName, userTableIdField, onDelete: .cascade))
            .field("client_id", .uuid, .required, .references("oauth_clients", "id", onDelete: .cascade))
            .unique(on: "refresh_token")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
