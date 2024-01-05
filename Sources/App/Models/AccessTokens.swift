//
//  AccessTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro AccessTokenModel() = #externalMacro(module: "VaporOAuthMacros", type: "AccessTokenModelMacro")

public final class AccessTokens: AccessToken {
    public static var schema: String = "oauth_access_tokens"
    public typealias User = UserTeachers
    
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
    
    @Field(key: "access_token")
    public var accessToken: String
    
    @Parent(key: "user_id")
    public var user: User
    
    @Parent(key: "client_id")
    public var client: Clients
    
    @Siblings(through: AccessTokenScopes.self, from: \.$accessToken, to: \.$scope)
    public var scopes: [Scopes]
    
    public init(expired: Date, accessToken: String, userID: User.IDValue, clientID: Clients.IDValue) {
        self.expired = expired
        self.isRevoked = false
        self.accessToken = accessToken
        self.$user.id = userID
        self.$client.id = clientID
    }
    
    public init() {
        
    }
}
