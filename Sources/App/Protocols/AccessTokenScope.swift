//
//  AccessTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol AccessTokenScope: Model {
    associatedtype AccessToken
    associatedtype Scope
    
    var accessToken: AccessToken { get set }
    var scope: Scope { get set }
}
