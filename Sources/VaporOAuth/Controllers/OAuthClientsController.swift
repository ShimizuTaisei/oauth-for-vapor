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
        oauthClients.get(use: getLists(req:))
        oauthClients.get("new", use: getRegisterForm(req:))
        oauthClients.post("new", use: postRegisterForm(req:))
    }
    
    func getLists(req: Request) async throws -> [OAuthClients] {
        return try await OAuthClients.query(on: req.db).all()
    }
    
    func getRegisterForm(req: Request) async throws -> View {
        return try await req.view.render(registerFormName)
    }
    
    func postRegisterForm(req: Request) async throws -> [String: String] {
        try OAuthClients.Create.validate(content: req)
        let create = try req.content.decode(OAuthClients.Create.self)
        
        var clientSecret: String?
        if create.isConfidentialClient {
            clientSecret = [UInt8].random(count: 32).base64
        }
        
        let client = try OAuthClients(name: create.name, clientSecret: clientSecret, redirectURIs: create.redirectUri, grantTypes: create.grantTypes, isConfidentialClient: create.isConfidentialClient)
        try await client.save(on: req.db)
        
        return ["client_id": client.id?.uuidString ?? "nil", "client_secret": clientSecret ?? "nil"]
    }
}
