//
//  RefreshToken.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol RefreshToken: Model {
    associatedtype User
    associatedtype AccessToken
    associatedtype Client
    associatedtype Scope
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var refreshToken: String { get set }
    var accessToken: AccessToken { get set }
    var user: User { get set }
    var client: Client { get set }
    var scopes: [Scope] { get set }
}
