//
//  AccessToken.swift
//
//
//  Created by Shimizu Taisei on 2024/01/03.
//


import Foundation

public protocol AccessToken {
    associatedtype IDValue: Codable, Hashable
    associatedtype User
    associatedtype Client
    associatedtype Scope
    var id: IDValue? { get set }
    var created: Date? { get set }
    var modified: Date? { get set }
    var expired: Date? { get set }
    var isRevoked: Bool { get set }
    var accessToken: String { get set }
    var user: User { get set }
    var client: Client { get set }
    var scopes: Scope { get set }
}
