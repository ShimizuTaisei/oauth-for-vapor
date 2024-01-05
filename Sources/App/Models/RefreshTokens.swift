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
    public var accessToken: AccessToken
    
    @Parent(key: "user_id")
    public var user: User
    
    @Parent(key: "client_id")
    public var client: Clients
    
    @Siblings(through: RefreshTokenScopes.self, from: \.$refreshToken, to: \.$scope)
    public var scopes: [Scopes]
    
    public init(expired: Date, refreshToken: String, accessToken: AccessToken.IDValue, userID: User.IDValue, clientID: Clients.IDValue) {
        self.expired = expired
        self.isRevoked = false
        self.refreshToken = refreshToken
        self.$accessToken.id = accessToken
        self.$user.id = userID
        self.$client.id = clientID
    }
    
    public init() {
        
    }
}
