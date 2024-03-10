//
//  RefreshTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

/// A protocol that defines members for table which associates refresh-token and scopes.
public protocol RefreshTokenScope: Model where IDValue == UUID {
    /// The type of refresh token. It should conform to ``RefreshToken``
    associatedtype RefreshTokenType: RefreshToken
    
    var refreshToken: RefreshTokenType { get set }
    var scope: OAuthScopes { get set }
}
