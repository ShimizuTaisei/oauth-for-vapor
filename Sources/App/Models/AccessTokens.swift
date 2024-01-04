//
//  AccessTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Vapor
import Fluent
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro AccessTokenModel() = #externalMacro(module: "VaporOAuthMacros", type: "AccessTokenModelMacro")

@AccessTokenModel
public final class AccessTokens: AccessToken {
    public static var schema: String = "oauth_access_tokens"
    public typealias User = UserTeachers
    
    @Parent(key: "user")
    public var user: UserTeachers
}
