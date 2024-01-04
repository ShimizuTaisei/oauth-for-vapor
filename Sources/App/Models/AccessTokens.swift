//
//  AccessTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Vapor
import Fluent
import VaporOAuthMacro

public class AccessTokens: AccessToken {
    public static var schema: String = "oauth_access_tokens"
    public typealias User = UserTeachers
    
    public typealias Client = Clients
    
    public typealias Scope = Scopes
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "created")
    public var created: Date?
    
    @Field(key: "modified")
    public var modified: Date?
    
    @Field(key: "expired")
    public var expired: Date?
    
    @Field(key: "revoked")
    public var isRevoked: Bool
    
    @Field(key: "access_token")
    public var accessToken: String
    
    @Parent(key: "user")
    public var user: UserTeachers
    
    @Parent(key: "client_id")
    public var client: Clients
    
    @Parent(key: "scopes")
    public var scopes: Scopes
    
    public required init() {
    }
    
}

public final class UserStudents {
    
}
