//
//  CreateOAuthAuthorizationCodeScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/28.
//  


import Foundation
import Fluent

public struct CreateOAuthAuthorizationCodeScopes: AsyncMigration {
    public var name: String
    var authCodeTableName: String
    
    public init(_ schema: String = "oauth_authorization_code_scopes", authCodeTableName: String) {
        self.name = schema
        self.authCodeTableName = authCodeTableName
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("authorization_code_id", .uuid, .required, .references(self.authCodeTableName, "id", onDelete: .cascade))
            .field("scope_id", .uuid, .required, .references("oauth_scopes", "id"))
            .unique(on: "authorization_code_id", "scope_id")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
