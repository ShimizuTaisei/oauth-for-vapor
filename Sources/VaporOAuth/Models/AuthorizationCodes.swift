//
//  AuthorizationCodes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro AuthorizationCodeModel() = #externalMacro(module: "VaporOAuthMacros", type: "AuthorizationCodeModelMacro")

@AuthorizationCodeModel
public final class AuthorizationCodes: AuthorizationCode {
    public static var schema: String = "oauth_authorization_codes"
    
    public typealias User = Users
    public typealias AccessTokenType = AccessTokens
    public typealias RefreshTokenType = RefreshTokens
}
