//
//  CreateOAuthAccessTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/28.
//  


import Foundation
import Fluent

/// Create a table which relates access-token and scopes.
public struct CreateOAuthAccessTokenScopes: AsyncMigration {
    public var name: String
    var accessTokenTableName: String
    
    ///
    /// - Parameters:
    ///   - schema: The name of table to create.
    ///   - accessTokenTableName: The name of access-token table which is refered from this table.
    @available(*, deprecated, renamed: "init", message: "Depricated in oauth-for-vapor v0.2.0\nUse init(_ configuration: OAuthMigrationConfiguration)")
    public init(_ schema: String = "oauth_access_token_scopes", accessTokenTableName: String = "oauth_access_tokens") {
        self.name = schema
        self.accessTokenTableName = accessTokenTableName
    }
    
    /// Initializer
    /// - Parameter configuration: The configuration object which contain informations about OAuth tables.
    public init(_ configuration: OAuthMigrationConfiguration) {
        self.name = configuration.accessTokenScopesScheme
        self.accessTokenTableName = configuration.accessTokensScheme
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("access_token_id", .uuid, .required, .references(self.accessTokenTableName, "id", onDelete: .cascade))
            .field("scope_id", .uuid, .required, .references("oauth_scopes", "id", onDelete: .restrict))
            .unique(on: "access_token_id", "scope_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
