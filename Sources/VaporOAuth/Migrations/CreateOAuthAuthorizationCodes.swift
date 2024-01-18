//
//  File.swift
//  
//  
//  Created by Shimizu Taisei on 2023/12/25.
//  


import Foundation
import Vapor
import Fluent

struct CreateOAuthAuthorizationCodes: AsyncMigration {
    var name: String
    var userTableName: String
    var userTableIdFiled: FieldKey
    var accessTokenTableName: String
    var refreshTokenTableName: String
    
    init(_ schema: String = "oauth_authorization_codes", userTableName: String, userTableIdFiled: FieldKey,
         accessTokenTableName: String = "oauth_access_tokens", refreshTokenTableName: String = "oauth_refresh_tokens") {
        self.name = schema
        self.userTableName = userTableName
        self.userTableIdFiled = userTableIdFiled
        self.accessTokenTableName = accessTokenTableName
        self.refreshTokenTableName = refreshTokenTableName
    }
    
    func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("expired", .string)
            .field("revoked", .bool)
            .field("used", .bool)
            .field("code", .string, .required)
            .field("redirect_uri", .string)
            .field("client_id", .uuid, .required, .references("oauth_clients", "id"))
            .field("user_id", .uuid, .required, .references(self.userTableName, userTableIdFiled))
            .field("access_token_id", .uuid, .references(self.accessTokenTableName, "id", onDelete: .cascade))
            .field("refresh_token_id", .uuid, .references(self.refreshTokenTableName, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
