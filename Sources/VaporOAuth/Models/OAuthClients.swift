//
//  Clients.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Vapor
import Fluent

public final class OAuthClients: OAuthClient {
    public static var schema: String = "oauth_clients"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Timestamp(key: "created", on: .create, format: .iso8601)
    public var created: Date?
    
    @Timestamp(key: "modified", on: .update, format: .iso8601)
    public var modified: Date?
    
    @Field(key: "name")
    public var name: String
    
    @OptionalField(key: "client_secret")
    public var clientSecret: String?
    
    @Field(key: "redirect_uris")
    public var redirectURIs: [String]
    
    @Field(key: "grant_types")
    public var grantTypes: [String]
    
    @Field(key: "confidential_client")
    public var isConfidentialClient: Bool
    
    public init() {
        
    }
    
    public init(name: String, clientSecret: String? = nil, redirectURIs: [String], grantTypes: [String], isConfidentialClient: Bool) throws {
        self.name = name
        if let clientSecret = clientSecret {
            self.clientSecret = try Bcrypt.hash(clientSecret)
        }
        self.redirectURIs = redirectURIs
        self.grantTypes = grantTypes
        self.isConfidentialClient = isConfidentialClient
    }
}

extension OAuthClients {
    struct Create: Content, Validatable {
        var name: String
        var redirectUri: [String]
        var grantTypes: [String]
        var isConfidentialClient: Bool
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty)
        }
    }
}
