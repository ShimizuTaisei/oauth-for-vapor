//
//  File.swift
//  
//  
//  Created by Shimizu Taisei on 2024/04/07.
//  


import Foundation
import Fluent

public struct OAuthMigrationConfiguration {
    var usersScheme: String
    var usersIDFieldKey: FieldKey
    
    var authorizationCodesScheme: String
    var authorizationCodeScopesScheme: String
    var accessTokensScheme: String
    var accessTokenScopesScheme: String
    var refreshTokensScheme: String
    var refreshTokenScopesScheme: String
    
    public init(usersScheme: String,
                usersIDFieldKey: FieldKey = "id",
                authorizationCodesScheme: String,
                authorizationCodeScopesScheme: String,
                accessTokensScheme: String,
                accessTokenScopesScheme: String,
                refreshTokensScheme: String,
                refreshTokenScopesScheme: String) {
        self.usersScheme = usersScheme
        self.usersIDFieldKey = usersIDFieldKey
        self.authorizationCodesScheme = authorizationCodesScheme
        self.authorizationCodeScopesScheme = authorizationCodeScopesScheme
        self.accessTokensScheme = accessTokensScheme
        self.accessTokenScopesScheme = accessTokenScopesScheme
        self.refreshTokensScheme = refreshTokensScheme
        self.refreshTokenScopesScheme = refreshTokenScopesScheme
    }
}
