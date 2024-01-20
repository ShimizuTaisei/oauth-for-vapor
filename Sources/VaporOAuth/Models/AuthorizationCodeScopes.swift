//
//  AuthorizationCodeScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro AuthorizationCodeScopeModel() = #externalMacro(module: "VaporOAuthMacros", type: "AuthorizationCodeScopeModelMacro")

@AuthorizationCodeScopeModel
public final class AuthorizationCodeScopes: AuthorizationCodeScope {
    public static var schema: String = "oauth_authorization_code_scopes"
    public typealias AuthorizationCodeType = AuthorizationCodes
}
