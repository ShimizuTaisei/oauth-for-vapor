//
//  CreateOAuthScopes.swift
//
//  
//  Created by Shimizu Taisei on 2023/12/26.
//  


import Foundation
import Vapor
import Fluent

struct CreateOAuthScopes: AsyncMigration {
    var name: String { "CreateOAuthScopes" }
    
    func prepare(on database: Database) async throws {
        try await database.schema("oauth_scopes")
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("name", .string)
            .field("explanation", .string)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("oauth_scopes").delete()
    }
}
