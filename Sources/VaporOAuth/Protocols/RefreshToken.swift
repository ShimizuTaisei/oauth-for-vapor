//
//  RefreshToken.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol RefreshToken: Model where IDValue == UUID {
    associatedtype User: Model
    associatedtype AccessTokenType: AccessToken
    
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var refreshToken: String { get set }
    var accessToken: AccessTokenType { get set }
    var user: User { get set }
    var client: OAuthClients { get set }
    var scopes: [OAuthScopes] { get set }
    
    init(expired: Date, refreshToken: String, accessTokenID: UUID, userID: User.IDValue, clientID: UUID)
    func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws
    static func queryRefreshToken(_ refreshToken: String, on database: Database) async throws -> Self?
}
