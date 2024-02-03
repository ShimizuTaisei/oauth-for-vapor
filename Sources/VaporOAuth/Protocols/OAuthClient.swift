//
//  Client.swift
//
//
//  Created by Shimizu Taisei on 2024/01/03.
//


import Foundation
import Fluent

/// A protocol that defines members for table which stores information of OAuth clients.
public protocol OAuthClient: Model {
    var created: Date? { get set }
    var modified: Date? { get set }
    var name: String { get set }
    var clientSecret: String? { get set }
    var redirectURIs: [String] { get set }
    var grantTypes: [String] { get set }
    var isConfidentialClient: Bool { get set }
}
