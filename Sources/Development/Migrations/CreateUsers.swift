//
//  CreateUsers.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent

struct CreateUsers: AsyncMigration {
    var name: String = "users"
    
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("created", .string)
            .field("modified", .string)
            .field("login_id", .string)
            .field("password", .string)
            .unique(on: "login_id")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
