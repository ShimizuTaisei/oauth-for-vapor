//
//  AuthorizationCodeScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol AuthorizationCodeScope: Model {
    associatedtype AuthorizationCode
    associatedtype Scope
    
    var authorizationCode: AuthorizationCode { get set }
    var scope: Scope { get set }
}
