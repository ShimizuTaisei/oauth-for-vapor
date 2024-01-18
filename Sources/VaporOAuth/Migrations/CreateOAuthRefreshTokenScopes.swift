//
//  CreateOAuthRefreshTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/28.
//  


import Foundation
import Fluent

struct CreateOAuthRefreshTokenScopes: AsyncMigration {
    var name: String
    var refreshTokenTableName: String
    
    init(_ scheme: String, refreshTokenTableName: String) {
        self.name = scheme
        self.refreshTokenTableName = refreshTokenTableName
    }
    
    func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("refresh_token_id", .uuid, .required, .references(refreshTokenTableName, "id", onDelete: .cascade))
            .field("scope_id", .uuid, .required, .references("oauth_scopes", "id"))
            .unique(on: "refresh_token_id", "scope_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
