//
//  RefreshTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent

public final class RefreshTokens: RefreshToken {
    public static var schema: String = "oauth_refresh_tokens"
    public typealias User = UserTeachers
    
    public typealias AccessToken = AccessTokens
    
    public typealias Client = Clients
    
    public typealias Scope = Scopes
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: "created", on: .create, format: .iso8601)
    public var created: Date?
    
    @Timestamp(key: "modified", on: .update, format: .iso8601)
    public var modified: Date?
    
    @Timestamp(key: "expired", on: .delete, format: .iso8601)
    public var expired: Date?
    
    @Field(key: "revoked")
    public var isRevoked: Bool
    
    @Field(key: "refresh_token")
    public var refreshToken: String
    
    @Parent(key: "access_token")
    public var accessToken: AccessTokens
    
    @Parent(key: "user_id")
    public var user: UserTeachers
    
    @Parent(key: "client_id")
    public var client: Clients
    
    @Siblings(through: RefreshTokenScopes.self, from: \.$refreshToken, to: \.$scope)
    public var scopes: [Scopes]
    
    public init(expired: Date, refreshToken: String, accessToken: AccessTokens, user: UserTeachers, client: Clients) {
        self.expired = expired
        self.isRevoked = false
        self.refreshToken = refreshToken
        self.accessToken = accessToken
        self.user = user
        self.client = client
    }
    
    public init() {
        
    }
}
