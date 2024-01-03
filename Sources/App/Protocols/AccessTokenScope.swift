//
//  AccessTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation

public protocol AccessTokenScope {
    associatedtype IDValue: Codable, Hashable
    associatedtype AccessToken
    associatedtype Scope
    
    var id: IDValue { get set }
    var accessToken: AccessToken { get set }
    var scope: Scope { get set }
}
