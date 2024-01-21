//
//  RefreshTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import VaporOAuth

@RefreshTokenScopeModel
public final class RefreshTokenScopes: RefreshTokenScope {
    public static var schema: String = "oauth_refresh_token_scopes"
    
    public typealias RefreshTokenType = RefreshTokens
}

