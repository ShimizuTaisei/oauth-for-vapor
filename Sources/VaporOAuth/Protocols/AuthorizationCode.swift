//
//  AuthorizationCode.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol AuthorizationCode: Model {
    associatedtype User: Model, ModelAuthenticatable
    associatedtype AccessTokenType: AccessToken
    associatedtype RefreshTokenType: RefreshToken
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var isUsed: Bool { get set }
    var code: String { get set }
    var redirectURI: String { get set }
    var client: OAuthClients { get set }
    var user: User { get set }
    var accessToken: AccessTokenType? { get set }
    var refreshToken: RefreshTokenType? { get set }
    var scopes: [OAuthScopes] { get set }
    
    init(expired: Date, code: String, redirectURI: String, clientID: UUID, userID: User.IDValue)
    func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws
    static func queryByAuthCode(on database: Database, code: String) async throws -> Self?
    func loadTokens(on database: Database) async throws
}
