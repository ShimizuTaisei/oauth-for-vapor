//
//  AuthorizationCodeScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

/// A protocol that defines members for table which associates authorization-code and scopes.
public protocol AuthorizationCodeScope: Model where IDValue == UUID {
    /// The type of authorization code table. It should conform to ``AuthorizationCode``
    associatedtype AuthorizationCodeType: AuthorizationCode
    
    var authorizationCode: AuthorizationCodeType { get set }
    var scope: OAuthScopes { get set }
}
