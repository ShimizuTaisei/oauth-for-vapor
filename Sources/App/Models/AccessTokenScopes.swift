//
//  AccessTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro AccessTokenScopeModel() = #externalMacro(module: "VaporOAuthMacros", type: "AccesstokenScopeModelMacro")

@AccessTokenScopeModel
public final class AccessTokenScopes: AccessTokenScope {
    public static var schema: String = "oauth_access_token_scopes"
    public typealias AccessToken = AccessTokens
}
