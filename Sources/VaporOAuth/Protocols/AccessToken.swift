//
//  AccessToken.swift
//
//
//  Created by Shimizu Taisei on 2024/01/03.
//


import Foundation
import Fluent

public protocol AccessToken: Model where IDValue == UUID {
    associatedtype User: Model
    associatedtype AccessTokenScopeType: AccessTokenScope
    
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var accessToken: String { get set }
    var user: User { get set }
    var client: OAuthClients { get set }
    var scopes: [OAuthScopes] { get set }
    
    init(expired: Date, accessToken: String, userID: User.IDValue, clientID: UUID)
    func setScope(_ scopes: [OAuthScopes], on database: Database) async throws
}
