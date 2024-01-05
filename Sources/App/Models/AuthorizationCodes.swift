//
//  AuthorizationCodes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent

public final class AuthorizationCodes: AuthorizationCode {
    public static var schema: String = "oauth_authorization_codes"
    
    public typealias User = UserTeachers
    public typealias AccessToken = AccessTokens
    public typealias RefreshToken = RefreshTokens
    
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
    
    @Field(key: "used")
    public var isUsed: Bool
    
    @Field(key: "code")
    public var code: String
    
    @Field(key: "redirect_uri")
    public var redirectURI: String
    
    @Parent(key: "client_id")
    public var client: Clients
    
    @Parent(key: "user_id")
    public var user: User
    
    @OptionalParent(key: "access_token_id")
    public var accessToken: AccessToken?
    
    @OptionalParent(key: "refresh_token_id")
    public var refreshToken: RefreshToken?
    
    @Siblings(through: AuthorizationCodeScopes.self, from: \.$authorizationCode, to: \.$scope)
    public var scopes: [Scopes]
    
    public init(expired: Date, code: String, redirectURI: String, clientID: Clients.IDValue, userID: User.IDValue) {
        self.expired = expired
        self.isRevoked = false
        self.isUsed = false
        self.code = code
        self.redirectURI = redirectURI
        self.$client.id = clientID
        self.$user.id = userID
    }
    
    public init() {
        
    }
}
