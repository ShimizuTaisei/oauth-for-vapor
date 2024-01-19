//
//  RefreshTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol RefreshTokenScope: Model {
    associatedtype RefreshToken
    
    var refreshToken: RefreshToken { get set }
    var scope: OAuthScopes { get set }
}
