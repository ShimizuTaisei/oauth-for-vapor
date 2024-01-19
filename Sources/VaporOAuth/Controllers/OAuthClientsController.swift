//
//  OAuthClientsController.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/16.
//  


import Foundation
import Vapor
import Fluent

struct OAuthClientsController: RouteCollection {
    let registerFormName: String = "oauthClientRegisterForm"
    func boot(routes: RoutesBuilder) throws {
        
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
