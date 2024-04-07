//
//  CreateOAuthAccessTokens.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/27.
//  


import Foundation
import Vapor
import Fluent

/// Create table which stores access-token.
public struct CreateOAuthAccessTokens: AsyncMigration {
    public var name: String
    var userTableName: String
    var userTableIdFiled: FieldKey
    
    /// 
    /// - Parameters:
    ///   - schema: The name of table to create.
    ///   - userTableName: The name of user table which is related to access-token.
    ///   - userTableIdFiled: The name of filed which contain user id.
    public init(_ schema: String = "oauth_access_tokens", userTableName: String, userTableIdFiled: FieldKey) {
        self.name = schema
        self.userTableName = userTableName
        self.userTableIdFiled = userTableIdFiled
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("expired", .string)
            .field("revoked", .bool)
            .field("access_token", .string, .required)
            .field("user_id", .uuid, .required, .references(userTableName, userTableIdFiled, onDelete: .cascade))
            .field("client_id", .uuid, .required, .references("oauth_clients", "id", onDelete: .cascade))
            .unique(on: "access_token")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
