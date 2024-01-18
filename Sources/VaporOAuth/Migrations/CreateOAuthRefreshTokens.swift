//
//  CreateOAuthRefreshTokens.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/27.
//  


import Foundation
import Vapor
import Fluent

struct CreateOAuthRefreshTokens: AsyncMigration {
    var name: String
    var userTableName: String
    var userTableIdField: FieldKey
    var accessTokenTableName: String
    
    init(_ schema: String = "oauth_refresh_tokens", userTableName: String, userTableIdField: FieldKey,
         accessTokenTableName: String = "oauth_access_tokens") {
        self.name = schema
        self.userTableName = userTableName
        self.userTableIdField = userTableIdField
        self.accessTokenTableName = accessTokenTableName
    }
    
    func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("expired", .string)
            .field("revoked", .bool)
            .field("refresh_token", .string, .required)
            .field("access_token_id", .uuid, .required, .references(self.accessTokenTableName, "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references(userTableName, userTableIdField))
            .field("client_id", .uuid, .required, .references("oauth_clients", "id"))
            .unique(on: "refresh_token")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
