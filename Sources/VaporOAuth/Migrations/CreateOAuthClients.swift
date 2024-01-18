//
//  File.swift
//  
//  
//  Created by Shimizu Taisei on 2023/12/24.
//  


import Foundation
import Vapor
import Fluent

struct CreateOAuthClients: AsyncMigration {
    var name: String { "oauth_clients" }
    
    func prepare(on database: Database) async throws {
        try await database.schema("oauth_clients")
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("name", .string)
            .field("client_secret", .string)
            .field("redirect_uris", .array(of: .string))
            .field("grant_types", .array(of: .string))
            .field("confidential_client", .bool)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("oauth_clients").delete()
    }
}
