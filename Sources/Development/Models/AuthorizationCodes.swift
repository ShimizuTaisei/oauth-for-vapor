//
//  AuthorizationCodes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Fluent
import VaporOAuth
import Crypto

@AuthorizationCodeModel
public final class AuthorizationCodes: AuthorizationCode {
    public static var schema: String = "oauth_authorization_codes"
    
    public typealias User = Users
    public typealias AccessTokenType = AccessTokens
    public typealias RefreshTokenType = RefreshTokens
}
