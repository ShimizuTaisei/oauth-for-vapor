//
//  OAuthClientsController.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/16.
//  


import Foundation
import Vapor
import Fluent

public struct OAuthClientsController: RouteCollection {
    let registerFormName: String = "oauthClientRegisterForm"
    public init() {}
    
    public func boot(routes: RoutesBuilder) throws {
        let oauthClients = routes.grouped("oauth", "clients")
        
        oauthClients.get(use: getLists(req:)) // Return list of clients.
        oauthClients.get("new", use: getRegisterForm(req:)) // Show form for new client registration.
        oauthClients.post("new", use: postRegisterForm(req:)) // Post new client information.
    }
    
    /// Return list of ``OAuthClients``.
    /// - Parameter req: Request.
    /// - Returns: The list of clients which is stored in database.
    func getLists(req: Request) async throws -> [OAuthClients] {
        return try await OAuthClients.query(on: req.db).all()
    }
    
    /// Show form for client registration.
    /// - Parameter req: Request.
    /// - Returns: The form view.
    func getRegisterForm(req: Request) async throws -> View {
        return try await req.view.render(registerFormName)
    }
    
    /// Post new client data from the form.
    /// - Parameter req: Request.
    /// - Returns: The dictionary which contains clientID and clientSecret.
    func postRegisterForm(req: Request) async throws -> [String: String] {
        try OAuthClients.Create.validate(content: req)
        let create = try req.content.decode(OAuthClients.Create.self)
        
        var clientSecret: String?
        if create.isConfidentialClient {
            clientSecret = [UInt8].random(count: 64).base64.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        }
        
        let client = try OAuthClients(name: create.name, clientSecret: clientSecret, redirectURIs: create.redirectUri, grantTypes: create.grantTypes, isConfidentialClient: create.isConfidentialClient)
        try await client.save(on: req.db)
        
        return ["client_id": client.id?.uuidString ?? "nil", "client_secret": clientSecret ?? "nil"]
    }
}
