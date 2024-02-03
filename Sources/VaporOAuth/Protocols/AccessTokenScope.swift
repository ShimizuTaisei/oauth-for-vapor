//
//  AccessTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

/// A protocol that defines menbers for table which associates access-token and scopes.
public protocol AccessTokenScope: Model {
    /// The type of access token table. It should conform to ``AccessToken``.
    associatedtype AccessTokenType: AccessToken
    
    var accessToken: AccessTokenType { get set }
    var scope: OAuthScopes { get set }
}
