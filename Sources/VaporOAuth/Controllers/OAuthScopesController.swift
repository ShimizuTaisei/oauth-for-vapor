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
    public init() {}
    
    public func boot(routes: RoutesBuilder) throws {
        let oauthScopes = routes.grouped("oauth", "scopes")
        
        oauthScopes.get(use: getLists(req:)) // Return list of scopes.
        oauthScopes.get("new", use: getRegisterForm(req:)) // Show form for adding new scope.
        oauthScopes.post("new", use: postRegisterForm(req:)) // Post new scope data from the form.
    }
    
    /// Return list of  scope in database.
    /// - Parameter req: Request.
    /// - Returns: List of ``OAuthScopes``
    func getLists(req: Request) async throws -> [OAuthScopes] {
        return try await OAuthScopes.query(on: req.db).all()
    }
    
    /// Show form for adding new scope.
    /// - Parameter req: Request.
    /// - Returns: The form.
    func getRegisterForm(req: Request) async throws -> View {
        return try await req.view.render(registerFormName)
    }
    
    /// Post new scope data from the form.
    /// - Parameter req: Request.
    /// - Returns: The instance of ``OAuthScope`` which was saved to the database.
    func postRegisterForm(req: Request) async throws -> OAuthScopes {
        try OAuthScopes.Create.validate(content: req)
        let create = try req.content.decode(OAuthScopes.Create.self)
        let scope = OAuthScopes(name: create.name, explanation: create.explanation)
        try await scope.save(on: req.db)
        return scope
    }
}
