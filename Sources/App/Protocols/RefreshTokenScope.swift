//
//  RefreshTokenScope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation

public protocol RefreshTokenScope {
    associatedtype IDValue: Codable, Hashable
    associatedtype RefreshToken
    associatedtype Scope
    
    var id: IDValue { get set }
    var refreshToken: RefreshToken { get set }
    var scope: Scope { get set }
}
