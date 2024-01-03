//
//  Scope.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent

public protocol Scope: Model {
    var created: Date? { get set }
    var modified: Date? { get set }
    var name: String { get set }
    var explanation: String? { get set }
}
