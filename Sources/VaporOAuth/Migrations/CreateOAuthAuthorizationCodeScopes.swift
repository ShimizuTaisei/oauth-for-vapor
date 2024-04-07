//
//  CreateOAuthAuthorizationCodeScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/28.
//  


import Foundation
import Fluent

/// Create table which relates authorization-code and scope.
public struct CreateOAuthAuthorizationCodeScopes: AsyncMigration {
    public var name: String
    var authCodeTableName: String
    
    
    ///
    /// - Parameters:
    ///   - schema: The name of table to create.
    ///   - authCodeTableName: The name of authorization-code table which is refered from this table.
    @available(*, deprecated, renamed: "init", message: "Depricated in oauth-for-vapor v0.2.0\nUse init(_ configuration: OAuthMigrationConfiguration)")
    public init(_ schema: String = "oauth_authorization_code_scopes", authCodeTableName: String = "oauth_authorization_codes") {
        self.name = schema
        self.authCodeTableName = authCodeTableName
    }
    
    /// Initializer.
    /// - Parameter configurations: The configuration object which contain informations about OAuth tables.
    public init(_ configurations: OAuthMigrationConfiguration) {
        self.name = configurations.authorizationCodeScopesScheme
        self.authCodeTableName = configurations.authorizationCodesScheme
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("authorization_code_id", .uuid, .required, .references(self.authCodeTableName, "id", onDelete: .cascade))
            .field("scope_id", .uuid, .required, .references("oauth_scopes", "id", onDelete: .restrict))
            .unique(on: "authorization_code_id", "scope_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
