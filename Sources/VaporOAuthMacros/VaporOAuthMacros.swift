//
//  VaporOAuthMacros.swift
//
//
//  Created by Shimizu Taisei on 2024/01/04.
//


import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AccessTokenModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Timestamp(key: "created", on: .create, format: .iso8601)
            public var created: Date?
            """,
            """
            @Timestamp(key: "modified", on: .update, format: .iso8601)
            public var modified: Date?
            """,
            """
            @Timestamp(key: "expired", on: .delete, format: .iso8601)
            public var expired: Date?
            """,
            """
            @Field(key: "revoked")
            public var isRevoked: Bool
            """,
            """
            @Field(key: "access_token")
            public var accessToken: String
            """,
            """
            @Parent(key: "user_id")
            public var user: User
            """,
            """
            @Parent(key: "client_id")
            public var client: Clients
            """,
            """
            @Siblings(through: AccessTokenScope.self, from: \\.$accessToken, to: \\.$scope)
            public var scopes: [Scopes]
            """,
            """
            public init(expired: Date, accessToken: String, userID: User.IDValue, clientID: Clients.IDValue) {
                self.expired = expired
                self.isRevoked = false
                self.accessToken = accessToken
                self.$user.id = userID
                self.$client.id = clientID
            }
            """,
            """
            public init() {

            }
            """,
        ]
    }
}

public struct AccesstokenScopeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Parent(key: "access_token_id")
            public var accessToken: AccessToken
            """,
            """
            @Parent(key: "scope_id")
            public var scope: Scopes
            """,
            """
            public init(accessTokenID: AccessToken.IDValue, scopeID: Scopes.IDValue) {
                self.$accessToken.id = accessTokenID
                self.$scope.id = scopeID
            }
            """,
            """
            public init() {
                    
            }
            """,
        ]
    }
}

public struct AuthorizationCodeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Timestamp(key: "created", on: .create, format: .iso8601)
            public var created: Date?
            """,
            """
            @Timestamp(key: "modified", on: .update, format: .iso8601)
            public var modified: Date?
            """,
            """
            @Timestamp(key: "expired", on: .delete, format: .iso8601)
            public var expired: Date?
            """,
            """
            @Field(key: "revoked")
            public var isRevoked: Bool
            """,
            """
            @Field(key: "used")
            public var isUsed: Bool
            """,
            """
            @Field(key: "code")
            public var code: String
            """,
            """
            @Field(key: "redirect_uri")
            public var redirectURI: String
            """,
            """
            @Parent(key: "client_id")
            public var client: Clients
            """,
            """
            @Parent(key: "user_id")
            public var user: User
            """,
            """
            @OptionalParent(key: "access_token_id")
            public var accessToken: AccessToken?
            """,
            """
            @OptionalParent(key: "refresh_token_id")
            public var refreshToken: RefreshToken?
            """,
            """
            @Siblings(through: AuthorizationCodeScopes.self, from: \\.$authorizationCode, to: \\.$scope)
            public var scopes: [Scopes]
            """,
            """
            public init(expired: Date, code: String, redirectURI: String, clientID: Clients.IDValue, userID: User.IDValue) {
                self.expired = expired
                self.isRevoked = false
                self.isUsed = false
                self.code = code
                self.redirectURI = redirectURI
                self.$client.id = clientID
                self.$user.id = userID
            }
            """,
            """
            public init() {
            
            }
            """,
        ]
    }
}

public struct AuthorizationCodeScopeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Parent(key: "authorization_code_id")
            public var authorizationCode: AuthorizationCode
            """,
            """
            @Parent(key: "scope_id")
            public var scope: Scopes
            """,
            """
            public init(authorizationCodeID: AuthorizationCode.IDValue, scopeID: Scopes.IDValue) {
                self.$authorizationCode.id = authorizationCodeID
                self.$scope.id = scopeID
            }
            """,
            """
            public init() {
                    
            }
            """,
        ]
    }
}

@main
struct VaporOAuthMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AccessTokenModelMacro.self,
        AccesstokenScopeModelMacro.self,
        AuthorizationCodeModelMacro.self,
        AuthorizationCodeScopeModelMacro.self,
    ]
}
