//
//  UsersController.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuth

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        let sessionAuth = users.grouped(Users.sessionAuthenticator())
        let credentialAuth = sessionAuth.grouped(Users.credentialsAuthenticator())
        let tokenAuth = users.grouped(OAuthAuthenticator<AccessTokens>())
        
        tokenAuth.get(use: getTop(req:))
//        sessionAuth.get(use: getTop(req:))
        sessionAuth.get("login", use: getLoginForm(req:))
        
        credentialAuth.post("login", use: postLoginForm(req:))
        
        users.get("register", use: getRegisterForm(req:))
        users.post("register", use: postRegisterForm(req:))
    }
    
    func getTop(req: Request) async throws -> Users {
        return try req.auth.require(Users.self)
    }
    
    func getLoginForm(req: Request) async throws -> View {
        return try await req.view.render("loginForm", ["action": "/users/login/"])
    }
    
    func postLoginForm(req: Request) async throws -> Users {
        return try req.auth.require(Users.self)
    }
    
    func getRegisterForm(req: Request) async throws -> View {
        return try await req.view.render("userRegisterForm")
    }
    
    func postRegisterForm(req: Request) async throws -> Users {
        try Users.Create.validate(content: req)
        let create = try req.content.decode(Users.Create.self)
        let user = try Users(loginID: create.loginID, password: create.password)
        try await user.save(on: req.db)
        return user
    }
}
