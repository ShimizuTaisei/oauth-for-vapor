//
//  AuthorizationCodeScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol AuthorizationCodeScope: Model {
    associatedtype AuthorizationCodeType
    
    var authorizationCode: AuthorizationCodeType { get set }
    var scope: OAuthScopes { get set }
}
