//
//  Users.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Fluent
import Vapor

public class Users: Model {
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
    
    public init(loginID: String, password: String) {
        self.loginID = loginID
        self.password = password
    }
}

public final class UserTeachers: Users, Content {
    @Field(key: "lname")
    var lname: String
}
