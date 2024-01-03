//
//  Scopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Vapor
import Fluent

public final class Scopes: Scope {
    public static var schema: String = "oauth_scopes"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: "created", on: .create, format: .iso8601)
    public var created: Date?
    
    @Timestamp(key: "modified", on: .update, format: .iso8601)
    public var modified: Date?
    
    @Field(key: "name")
    public var name: String
    
    @OptionalField(key: "explanation")
    public var explanation: String?
    
    public init(name: String, explanation: String?) {
        self.name = name
        self.explanation = explanation
    }
    
    public init() {
        
    }
}
