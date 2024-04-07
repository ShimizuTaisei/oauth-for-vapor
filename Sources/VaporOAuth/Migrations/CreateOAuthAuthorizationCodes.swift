//
//  File.swift
//  
//  
//  Created by Shimizu Taisei on 2023/12/25.
//  


import Foundation
import Vapor
import Fluent

/// Create table which stores authorization-code.
public struct CreateOAuthAuthorizationCodes: AsyncMigration {
    public var name: String
    var userTableName: String
    var userTableIdFiled: FieldKey
    var accessTokenTableName: String
    var refreshTokenTableName: String
    
    ///
    /// - Parameters:
    ///   - schema: The name of table to create
    ///   - userTableName: The name of user table which is refered from this table.
    ///   - userTableIdFiled: The name of field which contain user id.
    ///   - accessTokenTableName: The name of access-token table which is refered from this table.
    ///   - refreshTokenTableName: The name of refresh-token table which is refered from this table.
    public init(_ schema: String = "oauth_authorization_codes", userTableName: String, userTableIdFiled: FieldKey,
         accessTokenTableName: String = "oauth_access_tokens", refreshTokenTableName: String = "oauth_refresh_tokens") {
        self.name = schema
        self.userTableName = userTableName
        self.userTableIdFiled = userTableIdFiled
        self.accessTokenTableName = accessTokenTableName
        self.refreshTokenTableName = refreshTokenTableName
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema(self.name)
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("expired", .string)
            .field("revoked", .bool)
            .field("used", .bool)
            .field("code", .string, .required)
            .field("redirect_uri", .string)
            .field("code_challenge", .string)
            .field("code_challenge_method", .string)
            .field("client_id", .uuid, .required, .references("oauth_clients", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references(self.userTableName, userTableIdFiled, onDelete: .cascade))
            .field("access_token_id", .uuid, .references(self.accessTokenTableName, "id", onDelete: .cascade))
            .field("refresh_token_id", .uuid, .references(self.refreshTokenTableName, "id", onDelete: .cascade))
            .unique(on: "code")
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema(self.name).delete()
    }
}
