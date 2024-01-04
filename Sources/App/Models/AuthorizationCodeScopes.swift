//
//  AuthorizationCodeScopes.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import Vapor
import Fluent

public final class AuthorizationCodeScopes: AuthorizationCodeScope {
    public static var schema: String = "oauth_authorization_code_scopes"
    public typealias AuthorizationCode = AuthorizationCodes
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "authorization_code_id")
    public var authorizationCode: AuthorizationCodes
    
    @Parent(key: "scope_id")
    public var scope: Scopes
    
    public init(authorizationCode: AuthorizationCodes, scope: Scopes) {
        self.authorizationCode = authorizationCode
        self.scope = scope
    }
    
    public init() {
        
    }
}
