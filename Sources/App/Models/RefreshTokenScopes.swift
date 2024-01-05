//
//  RefreshTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro RefreshTokenScopeModel() = #externalMacro(module: "VaporOAuthMacros", type: "RefreshTokenScopeModelMacro")

@RefreshTokenScopeModel
public final class RefreshTokenScopes: RefreshTokenScope {
    public static var schema: String = "oauth_refresh_token_scopes"
    
    public typealias RefreshToken = RefreshTokens
}
