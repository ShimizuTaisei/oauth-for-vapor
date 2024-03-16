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

// MARK: - AccessTokens
public struct AccessTokenModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let decl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        let name = decl.name.text
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
            public var client: OAuthClients
            """,
            """
            @Siblings(through: AccessTokenScopeType.self, from: \\.$accessToken, to: \\.$scope)
            public var scopes: [OAuthScopes]
            """,
            """
            public init(expired: Date, accessToken: String, userID: User.IDValue, clientID: OAuthClients.IDValue) throws {
                self.expired = expired
                self.isRevoked = false
                self.accessToken = try Bcrypt.hash(accessToken)
                self.$user.id = userID
                self.$client.id = clientID
            }
            """,
            """
            public init() {

            }
            """,
            """
            public func setScope(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
            """,
            """
            /// Return revoked tokens to delete.
            /// - Parameter database: Database.
            /// - Returns: The list of revoked or expired tokens.
            public static func forDelete(on database: Database) async throws -> [\(raw: name)] {
                let revokedAccessTokens = try await \(raw: name).query(on: database).group(.or) { group in
                    group.filter(\\.$isRevoked == true).filter(\\.$expired < Date())
                }.withDeleted().all()
                return revokedAccessTokens
            }
            """,
            """
            public static func findByID(id: UUID, on database: Database) async throws -> \(raw: name)? {
                let accessToken = try await \(raw: name).query(on: database).filter(\\.$id == id).with(\\.$user).with(\\.$client).with(\\.$scopes).first()
                return accessToken
            }
            """,
        ]
    }
}

// MARK: - AccessTokenScopes
public struct AccesstokenScopeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Parent(key: "access_token_id")
            public var accessToken: AccessTokenType
            """,
            """
            @Parent(key: "scope_id")
            public var scope: OAuthScopes
            """,
            """
            public init(accessTokenID: AccessTokenType.IDValue, scopeID: OAuthScopes.IDValue) {
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

// MARK: - AuthorizationCodes
public struct AuthorizationCodeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let decl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        let name = decl.name.text

        let typealiases = decl.memberBlock.members.compactMap { member in
            return member.decl.as(TypeAliasDeclSyntax.self)
        }
        
//        let userAlias = typealiases.first(where: { $0.name.text == "User" })
//        let accessTokenAlias = typealiases.first(where: { $0.name.text == "AccessTokenType" })
//        let refreshTokenAlias = typealiases.first(where: { $0.name.text == "RefreshTokenType" })
//        
//        let userSyntax = userAlias?.initializer.value.as(IdentifierTypeSyntax.self)
//        let accessTokenSyntax = accessTokenAlias?.initializer.value.as(IdentifierTypeSyntax.self)
//        let refreshTokenSyntax = refreshTokenAlias?.initializer.value.as(IdentifierTypeSyntax.self)
//    
//        guard let userTypeName = userSyntax?.name.text,
//              let accessTokenName = accessTokenSyntax?.name.text,
//              let refreshTokenName = refreshTokenSyntax?.name.text else {
//            return []
//        }
        
        let authorizationCodeScopeAlias = typealiases.first(where: { $0.name.text == "AuthorizationCodeScopeType" })
        let authorizationCodeScopeSyntax = authorizationCodeScopeAlias?.initializer.value.as(IdentifierTypeSyntax.self)
        guard let authorizationCodeScopeName = authorizationCodeScopeSyntax?.name.text else {
            return []
        }
       
        
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
            @Field(key: "code_challenge")
            public var codeChallenge: String
            """,
            """
            @Field(key: "code_challenge_method")
            public var codeChallengeMethod: String
            """,
            """
            @Parent(key: "client_id")
            public var client: OAuthClients
            """,
            """
            @Parent(key: "user_id")
            public var user: User
            """,
            """
            @OptionalParent(key: "access_token_id")
            public var accessToken: AccessTokenType?
            """,
            """
            @OptionalParent(key: "refresh_token_id")
            public var refreshToken: RefreshTokenType?
            """,
            """
            @Siblings(through: \(raw: authorizationCodeScopeName).self, from: \\.$authorizationCode, to: \\.$scope)
            public var scopes: [OAuthScopes]
            """,
            """
            public init(expired: Date, code: String, redirectURI: String, codeChallenge: String, codeChallengeMethod: String, clientID: UUID, userID: UUID) throws {
                self.expired = expired
                self.isRevoked = false
                self.isUsed = false
                self.code = try Bcrypt.hash(code)
                self.redirectURI = redirectURI
                self.codeChallenge = codeChallenge
                self.codeChallengeMethod = codeChallengeMethod
                self.$client.id = clientID
                self.$user.id = userID
            }
            """,
            """
            public init() {
            
            }
            """,
            """
            public func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
            """,
            """
            public static func queryByAuthCode(on database: Database, code: String) async throws -> \(raw: name)? {
                let authCode = try await \(raw: name).query(on: database).filter(\\.$code == code).with(\\.$user).with(\\.$scopes).first()
                return authCode
            }
            """,
            """
            public func loadTokens(on database: Database) async throws {
                try await self.$accessToken.load(on: database)
                try await self.$refreshToken.load(on: database)
            }
            """,
            """
            public func setTokens(accessTokenID: UUID, refreshTokenID: UUID) {
                self.$accessToken.id = accessTokenID
                self.$refreshToken.id = refreshTokenID
            }
            """,
            """
            /// Return revoked codes to delete.
            /// - Parameter database: Database.
            /// - Returns: The list of revoked or expired codes.
            public static func forDelete(on database: Database) async throws -> [\(raw: name)] {
                let revokedAuthCodes = try await \(raw: name).query(on: database).group(.or) { group in
                    group.filter(\\.$isRevoked == true).filter(\\.$expired < Date())
                }.withDeleted().all()
                return revokedAuthCodes
            }
            """,
            """
            public static func findByID(id: UUID, on database: Database) async throws -> \(raw: name)? {
                let authCode = try await \(raw: name).query(on: database).filter(\\.$id == id).with(\\.$user).with(\\.$scopes).first()
                return authCode
            }
            """,
        ]
    }
}

// MARK: - AuthorizationCodeScopes
public struct AuthorizationCodeScopeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Parent(key: "authorization_code_id")
            public var authorizationCode: AuthorizationCodeType
            """,
            """
            @Parent(key: "scope_id")
            public var scope: OAuthScopes
            """,
            """
            public init(authorizationCodeID: AuthorizationCodeType.IDValue, scopeID: OAuthScopes.IDValue) {
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

// MARK: - RefreshTokens
public struct RefreshTokenModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let decl = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        let name = decl.name.text
        
        let typealiases = decl.memberBlock.members.compactMap { member in
            return member.decl.as(TypeAliasDeclSyntax.self)
        }
        
        let refreshTokenScopeAlias = typealiases.first(where: { $0.name.text == "RefreshTokenScopeType" })
        let refreshTokenScopeSyntax = refreshTokenScopeAlias?.initializer.value.as(IdentifierTypeSyntax.self)
        guard let refreshTokenScopeName = refreshTokenScopeSyntax?.name.text else {
            return []
        }
        
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
            @Field(key: "refresh_token")
            public var refreshToken: String
            """,
            """
            @OptionalParent(key: "access_token_id")
            public var accessToken: AccessTokenType?
            """,
            """
            @Parent(key: "user_id")
            public var user: User
            """,
            """
            @Parent(key: "client_id")
            public var client: OAuthClients
            """,
            """
            @Siblings(through: \(raw: refreshTokenScopeName).self, from: \\.$refreshToken, to: \\.$scope)
            public var scopes: [OAuthScopes]
            """,
            """
            public init(expired: Date, refreshToken: String, accessTokenID: UUID, userID: User.IDValue, clientID: UUID) throws {
                self.expired = expired
                self.isRevoked = false
                self.refreshToken = try Bcrypt.hash(refreshToken)
                self.$accessToken.id = accessTokenID
                self.$user.id = userID
                self.$client.id = clientID
            }
            """,
            """
            public init() {
                
            }
            """,
            """
            public func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
            """,
            """
            public static func queryRefreshToken(_ refreshToken: String, on database: Database) async throws -> \(raw: name)? {
                let refreshToken = try await \(raw: name).query(on: database).filter(\\.$refreshToken == refreshToken).with(\\.$accessToken).with(\\.$user).with(\\.$client).with(\\.$scopes).first()
                return refreshToken
            }
            """,
            """
            /// Return revoked tokens to delete.
            /// - Parameter database: Database.
            /// - Returns: The list of revoked or expired tokens.
            public static func forDelete(on database: Database) async throws -> [\(raw: name)] {
                let revokedRefreshTokens = try await \(raw: name).query(on: database).group(.or) { group in
                    group.filter(\\.$isRevoked == true).filter(\\.$expired < Date())
                }.withDeleted().all()
                return revokedRefreshTokens
            }
            """,
            """
            public static func findByID(id: UUID, on database: Database) async throws -> \(raw: name)? {
                let refreshToken = try await \(raw: name).query(on: database).filter(\\.$id == id).with(\\.$accessToken, withDeleted: true).with(\\.$user).with(\\.$client).with(\\.$scopes).first()
                return refreshToken
            }
            """,
        ]
    }
}

// MARK: - RefreshTokenScopes
public struct RefreshTokenScopeModelMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return [
            """
            @ID(key: .id)
            public var id: UUID?
            """,
            """
            @Parent(key: "refresh_token_id")
            public var refreshToken: RefreshTokenType
            """,
            """
            @Parent(key: "scope_id")
            public var scope: OAuthScopes
            """,
            """
            public init(refreshTokenID: RefreshTokenType.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$refreshToken.id = refreshTokenID
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

// MARK: Authenticator
public struct AccessTokenAuthenticatorMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let syntax = try ExtensionDeclSyntax("""
            extension \(type.trimmed): AsyncBearerAuthenticator {
                func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
                    let hashedToken = SHA512.hash(data: bearer.token.data(using: .utf8)!).hexEncodedString()
                    let accessTokens = try await AccessTokens.query(on: request.db).filter(\\.$accessToken == hashedToken).with(\\.$user).all()
                    guard accessTokens.count == 1, let accessToken = accessTokens.first else {
                        throw Abort(.unauthorized)
                    }
                    if accessToken.accessToken == hashedToken {
                        request.auth.login(accessToken.user)
                    }
                }

            }
            """)
        
        return [syntax]
    }
}

@main
struct VaporOAuthMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AccessTokenModelMacro.self,
        AccesstokenScopeModelMacro.self,
        AuthorizationCodeModelMacro.self,
        AuthorizationCodeScopeModelMacro.self,
        RefreshTokenModelMacro.self,
        RefreshTokenScopeModelMacro.self,
        AccessTokenAuthenticatorMacro.self
    ]
}


