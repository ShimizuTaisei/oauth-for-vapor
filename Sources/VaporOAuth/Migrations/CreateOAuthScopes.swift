//
//  CreateOAuthScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/26.
//  


import Foundation
import Vapor
import Fluent

public struct CreateOAuthScopes: AsyncMigration {
    public var name: String { "CreateOAuthScopes" }
    
    public init() {
        
    }
    
    public func prepare(on database: Database) async throws {
        try await database.schema("oauth_scopes")
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("name", .string)
            .field("explanation", .string)
            .create()
    }
    
    public func revert(on database: Database) async throws {
        try await database.schema("oauth_scopes").delete()
    }
}
