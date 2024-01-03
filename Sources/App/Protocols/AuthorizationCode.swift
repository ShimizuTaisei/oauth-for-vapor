//
//  AuthorizationCode.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation

public protocol AuthorizationCode {
    associatedtype IDValue: Codable, Hashable
    associatedtype User
    associatedtype Client
    associatedtype Scope
    associatedtype AccessToken
    associatedtype RefreshToken
    var id: IDValue? { get set }
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var isUsed: Bool { get set }
    var code: String { get set }
    var redirectURI: String { get set }
    var client: Client { get set }
    var user: User { get set }
    var accessToken: AccessToken { get set }
    var refreshToken: RefreshToken { get set }
    var scopes: [Scope] { get set }
}
