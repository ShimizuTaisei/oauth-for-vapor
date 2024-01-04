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
            "public typealias Client = Clients",
            "public typealias Scope = Scopes",
            """
                @ID(key: .id)
                public var id: UUID?
            """,
            """
                @Field(key: "created")
                public var created: Date?
            """,
            """
                @Field(key: "modified")
                public var modified: Date?
            """,
            """
                @Field(key: "expired")
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
                @Parent(key: "client_id")
                public var client: Clients
            """,
            """
                @Parent(key: "scopes")
                public var scopes: Scopes
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
