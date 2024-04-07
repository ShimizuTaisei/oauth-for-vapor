//
//  CreateOAuthRefreshTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/28.
//  


import Foundation
import Fluent

/// Create table which relates refresh-token and scope.
public struct CreateOAuthRefreshTokenScopes: AsyncMigration {
    public var name: String
    var refreshTokenTableName: String
    
    ///
    /// - Parameters:
    ///   - scheme: The name of table to create.
    ///   - refreshTokenTableName: The name of refresh-token table which refered from this table.
    @available(*, deprecated, renamed: "init", message: "Depricated in oauth-for-vapor v0.2.0\nUse init(_ configuration: OAuthMigrationConfiguration)")
    public init(_ scheme: String = "oauth_refresh_token_scopes", refreshTokenTableName: String = "oauth_refresh_tokens") {
        self.name = scheme
        self.refreshTokenTableName = refreshTokenTableName
    }
    
    /// Initializer.
    /// - Parameter configurations: The configuration object which contain informations about OAuth tables.
    public init(_ configurations: OAuthMigrationConfiguration) {
        self.name = configurations.refreshTokenScopesScheme
        self.refreshTokenTableName = configurations.refreshTokenScopesScheme
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("refresh_token_id", .uuid, .required, .references(refreshTokenTableName, "id", onDelete: .cascade))
            .field("scope_id", .uuid, .required, .references("oauth_scopes", "id", onDelete: .restrict))
            .unique(on: "refresh_token_id", "scope_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
