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
    public typealias Scope = Scopes
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "access_token_id")
    public var accessToken: AccessTokens
    
    @Parent(key: "scope_id")
    public var scope: Scopes
    
    public init(accessToken: AccessTokens, scope: Scopes) {
        self.accessToken = accessToken
        self.scope = scope
    }
    
    public init() {
        
    }
}
