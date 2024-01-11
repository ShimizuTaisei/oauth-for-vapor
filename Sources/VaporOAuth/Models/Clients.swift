//
//  Clients.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  


import Foundation
import Vapor
import Fluent

public final class Clients: Client {
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
