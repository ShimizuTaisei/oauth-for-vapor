//
//  AccessTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent

public final class AccessTokenScopes: AccessTokenScope {
    public static var schema: String = "oauth_access_token_scopes"
    public typealias AccessToken = AccessTokens
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "access_token_id")
    public var accessToken: AccessToken
    
    @Parent(key: "scope_id")
    public var scope: Scopes
    
    public init(accessTokenID: AccessToken.IDValue, scopeID: Scopes.IDValue) {
        self.$accessToken.id = accessTokenID
        self.$scope.id = scopeID
    }
    
    public init() {
        
    }
}
