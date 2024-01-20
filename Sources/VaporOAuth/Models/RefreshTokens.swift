//
//  RefreshTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro RefreshTokenModel() = #externalMacro(module: "VaporOAuthMacros", type: "RefreshTokenModelMacro")


@RefreshTokenModel
public final class RefreshTokens: RefreshToken {
    public static var schema: String = "oauth_refresh_tokens"
    
    public typealias User = Users
    public typealias AccessTokenType = AccessTokens
}
