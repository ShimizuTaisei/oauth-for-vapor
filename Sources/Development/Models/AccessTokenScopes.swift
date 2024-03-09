//
//  AccessTokenScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import VaporOAuth

@AccessTokenScopeModel
public final class AccessTokenScopes: AccessTokenScope {
    public static var schema: String = "oauth_access_token_scopes"
    public typealias AccessTokenType = AccessTokens
}
