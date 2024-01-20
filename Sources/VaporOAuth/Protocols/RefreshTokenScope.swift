//
//  RefreshTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol RefreshTokenScope: Model {
    associatedtype RefreshTokenType: RefreshToken
    
    var refreshToken: RefreshTokenType { get set }
    var scope: OAuthScopes { get set }
}
