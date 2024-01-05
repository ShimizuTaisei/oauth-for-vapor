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

@main
struct VaporOAuthMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AccessTokenModelMacro.self,
    ]
}
