//
//  AccessTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol AccessTokenScope: Model {
    associatedtype AccessTokenType: AccessToken
    
    var accessToken: AccessTokenType { get set }
    var scope: OAuthScopes { get set }
}
