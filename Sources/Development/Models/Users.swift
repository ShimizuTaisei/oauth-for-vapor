//
//  Users.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent
import Vapor

public final class Users: Model, Content {
    public static var schema: String = "users"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: "created", on: .create, format: .iso8601)
    public var created: Date?
    
    @Timestamp(key: "modified", on: .update, format: .iso8601)
    public var modified: Date?
    
    @Field(key: "login_id")
    public var loginID: String
    
    @Field(key: "password")
    public var password: String
    
    required public init() {
        
    }
    
    public init(loginID: String, password: String) throws {
        self.loginID = loginID
        self.password = try Bcrypt.hash(password)
    }
}

extension Users {
    struct Create: Content {
        var loginID: String
        var password: String
    }
}

extension Users.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("loginID", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: !.empty)
    }
}

extension Users: ModelAuthenticatable {
    public static let usernameKey = \Users.$loginID
    public static let passwordHashKey = \Users.$password
    
    public func verify(password: String) throws -> Bool {
        let isValid = try Bcrypt.verify(password, created: self.password)
        return isValid
    }
}

extension Users: ModelCredentialsAuthenticatable {}
extension Users: ModelSessionAuthenticatable {}
