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
    public init(_ schema: String = "oauth_refresh_tokens", userTableName: String, userTableIdField: FieldKey,
         accessTokenTableName: String = "oauth_access_tokens") {
        self.name = schema
        self.userTableName = userTableName
        self.userTableIdField = userTableIdField
        self.accessTokenTableName = accessTokenTableName
    }
    
    public func prepare(on database: Database) async throws {
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
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
