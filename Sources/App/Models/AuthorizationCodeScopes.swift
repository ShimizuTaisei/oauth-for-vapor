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
    public var authorizationCode: AuthorizationCode
    
    @Parent(key: "scope_id")
    public var scope: Scopes
    
    public init(authorizationCodeID: AuthorizationCode.IDValue, scopeID: Scopes.IDValue) {
        self.$authorizationCode.id = authorizationCodeID
        self.$scope.id = scopeID
    }
    
    public init() {
        
    }
}
