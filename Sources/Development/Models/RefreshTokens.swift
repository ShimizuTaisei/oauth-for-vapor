//
//  RefreshTokens.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import Vapor
import VaporOAuth
import Crypto

@RefreshTokenModel
public final class RefreshTokens: RefreshToken {
    public static var schema: String = "oauth_refresh_tokens"
    
    public typealias User = Users
    public typealias AccessTokenType = AccessTokens
}

