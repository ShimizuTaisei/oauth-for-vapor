//
//  AuthorizationCodeScoopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import VaporOAuth

@AuthorizationCodeScopeModel
public final class AuthorizationCodeScopes: AuthorizationCodeScope {
    public static var schema: String = "oauth_authorization_code_scopes"
    public typealias AuthorizationCodeType = AuthorizationCodes
}

