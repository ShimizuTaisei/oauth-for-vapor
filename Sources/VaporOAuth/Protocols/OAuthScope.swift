//
//  Scope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

/// A protocol that defines members for table which stores information of OAuth scopes.
public protocol OAuthScope: Model {
    var created: Date? { get set }
    var modified: Date? { get set }
    var name: String { get set }
    var explanation: String? { get set }
}
