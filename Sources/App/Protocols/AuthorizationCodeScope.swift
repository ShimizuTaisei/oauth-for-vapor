//
//  AuthorizationCodeScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation

public protocol AuthorizationCodeScope {
    associatedtype IDValue: Codable, Hashable
    associatedtype AuthorizationCode
    associatedtype Scope
    
    var id: IDValue { get set }
    var authorizationCode: AuthorizationCode { get set }
    var scope: Scope { get set }
}
