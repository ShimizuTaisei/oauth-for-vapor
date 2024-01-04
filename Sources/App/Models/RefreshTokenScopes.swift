//
//  RefreshTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent

public final class RefreshTokenScopes: RefreshTokenScope {
    public static var schema: String = "oauth_refresh_token_scopes"
    
    public typealias RefreshToken = RefreshTokens
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "refresh_token_id")
    public var refreshToken: RefreshTokens
    
    @Parent(key: "refresh_token_id")
    public var scope: Scopes
    
    public init(refreshToken: RefreshTokens, scope: Scopes) {
        self.refreshToken = refreshToken
        self.scope = scope
    }
    
    public init() {
        
    }
}
