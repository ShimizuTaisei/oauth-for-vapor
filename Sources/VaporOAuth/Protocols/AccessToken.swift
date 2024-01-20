//
//  AccessToken.swift
//
//
//  Created by Shimizu Taisei on 2024/01/03.
//


import Foundation
import Fluent

public protocol AccessToken: Model {
    associatedtype User
    associatedtype AccessTokenScope
    
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var accessToken: String { get set }
    var user: User { get set }
    var client: OAuthClients { get set }
    var scopes: [OAuthScopes] { get set }
}