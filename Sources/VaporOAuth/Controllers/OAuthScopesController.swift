//
//  OAuthScopeController.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/11.
//  


import Foundation
import Vapor
import Fluent

public struct OAuthScopesController: RouteCollection {
    let registerFormName: String = "oauthScopeRegisterForm"
    public func boot(routes: RoutesBuilder) throws {
        let oauthScopes = routes.grouped("oauth", "scopes")
        
        oauthScopes.get("new", use: getRegisterForm(req:))
        oauthScopes.post("new", use: postRegisterForm(req:))
    }
    
    func getRegisterForm(req: Request) async throws -> View {
        return try await req.view.render(registerFormName)
    }
    
    func postRegisterForm(req: Request) async throws -> OAuthScopes {
        try OAuthScopes.Create.validate(content: req)
        let create = try req.content.decode(OAuthScopes.Create.self)
        let scope = OAuthScopes(name: create.name, explanation: create.explanation)
        try await scope.save(on: req.db)
        return scope
    }
}
