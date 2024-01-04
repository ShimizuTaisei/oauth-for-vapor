//
//  AuthorizationCodes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent

public final class AuthorizationCodes: AuthorizationCode {
    public static var schema: String = "oauth_authorization_codes"
    
    public typealias User = UserTeachers
    
    public typealias Client = Clients
    
    public typealias Scope = Scopes
    
    public typealias AccessToken = AccessTokens
    
    public typealias RefreshToken = <#type#>
    
    
}
