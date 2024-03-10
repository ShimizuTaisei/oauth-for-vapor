//
//  VaporOAuthMacrosTests.swift
//
//
//  Created by Shimizu Taisei on 2024/01/05.
//


import Foundation
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

@testable import VaporOAuthMacros
import XCTVapor

final class VaporOAuthMacrosTests: XCTestCase {
    // MARK: - AccessTokens
    func testAccessToken() throws {
        assertMacroExpansion("""
        @AccessTokenModel
        public final class AccessTokens: AccessToken {
            public static var schema: String = "oauth_access_tokens"
            public typealias User = Users
            public typealias AccessTokenScopeType = AccessTokenScopes
        }
        """, expandedSource: """
        public final class AccessTokens: AccessToken {
            public static var schema: String = "oauth_access_tokens"
            public typealias User = Users
            public typealias AccessTokenScopeType = AccessTokenScopes

            @ID(key: .id)
            public var id: UUID?

            @Timestamp(key: "created", on: .create, format: .iso8601)
            public var created: Date?

            @Timestamp(key: "modified", on: .update, format: .iso8601)
            public var modified: Date?

            @Timestamp(key: "expired", on: .delete, format: .iso8601)
            public var expired: Date?

            @Field(key: "revoked")
            public var isRevoked: Bool

            @Field(key: "access_token")
            public var accessToken: String

            @Parent(key: "user_id")
            public var user: User

            @Parent(key: "client_id")
            public var client: OAuthClients

            @Siblings(through: AccessTokenScopeType.self, from: \\.$accessToken, to: \\.$scope)
            public var scopes: [OAuthScopes]

            public init(expired: Date, accessToken: String, userID: User.IDValue, clientID: OAuthClients.IDValue) {
                self.expired = expired
                self.isRevoked = false
                self.accessToken = SHA512.hash(data: Data(accessToken.utf8)).hexEncodedString()
                self.$user.id = userID
                self.$client.id = clientID
            }

            public init() {

            }
        
            public func setScope(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
        
            /// Return revoked tokens to delete.
            /// - Parameter database: Database.
            /// - Returns: The list of revoked or expired tokens.
            public static func forDelete(on database: Database) async throws -> [AccessTokens] {
                let revokedAccessTokens = try await AccessTokens.query(on: database).group(.or) { group in
                    group.filter(\\.$isRevoked == true).filter(\\.$expired < Date())
                } .withDeleted().all()
                return revokedAccessTokens
            }
        }
        """
        , macros: ["AccessTokenModel": AccessTokenModelMacro.self])
    }
    
    // MARK: - AccessTokenScopes
    func testAccesTokenScope() throws {
        assertMacroExpansion("""
        @AccessTokenScopeModel
        public final class AccessTokenScopes: AccessTokenScope {
            public static var schema: String = "oauth_access_token_scopes"
            public typealias AccessTokenType = AccessTokens
        }
        """, expandedSource: """
        public final class AccessTokenScopes: AccessTokenScope {
            public static var schema: String = "oauth_access_token_scopes"
            public typealias AccessTokenType = AccessTokens

            @ID(key: .id)
            public var id: UUID?

            @Parent(key: "access_token_id")
            public var accessToken: AccessTokenType

            @Parent(key: "scope_id")
            public var scope: OAuthScopes

            public init(accessTokenID: AccessTokenType.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$accessToken.id = accessTokenID
                self.$scope.id = scopeID
            }

            public init() {

            }
        }
        """,
        macros: ["AccessTokenScopeModel": AccesstokenScopeModelMacro.self])
    }
    
    // MARK: - AuthorizationCodes
    func testAuthorizationCode() throws {
        assertMacroExpansion("""
        @AuthorizationCodeModel
        public final class AuthorizationCodes: AuthorizationCode {
            public static var schema: String = "oauth_authorization_codes"
            
            public typealias User = Users
            public typealias AccessTokenType = AccessTokens
            public typealias RefreshTokenType = RefreshTokens
        }
        """, expandedSource: """
        public final class AuthorizationCodes: AuthorizationCode {
            public static var schema: String = "oauth_authorization_codes"
            
            public typealias User = Users
            public typealias AccessTokenType = AccessTokens
            public typealias RefreshTokenType = RefreshTokens

            @ID(key: .id)
            public var id: UUID?

            @Timestamp(key: "created", on: .create, format: .iso8601)
            public var created: Date?

            @Timestamp(key: "modified", on: .update, format: .iso8601)
            public var modified: Date?

            @Timestamp(key: "expired", on: .delete, format: .iso8601)
            public var expired: Date?

            @Field(key: "revoked")
            public var isRevoked: Bool

            @Field(key: "used")
            public var isUsed: Bool

            @Field(key: "code")
            public var code: String

            @Field(key: "redirect_uri")
            public var redirectURI: String
        
            @Field(key: "code_challenge")
            public var codeChallenge: String
        
            @Field(key: "code_challenge_method")
            public var codeChallengeMethod: String

            @Parent(key: "client_id")
            public var client: OAuthClients

            @Parent(key: "user_id")
            public var user: User

            @OptionalParent(key: "access_token_id")
            public var accessToken: AccessTokenType?

            @OptionalParent(key: "refresh_token_id")
            public var refreshToken: RefreshTokenType?

            @Siblings(through: AuthorizationCodeScopes.self, from: \\.$authorizationCode, to: \\.$scope)
            public var scopes: [OAuthScopes]

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

            public init() {

            }
        
            public func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
        
            public static func queryByAuthCode(on database: Database, code: String) async throws -> AuthorizationCodes? {
                let authCode = try await AuthorizationCodes.query(on: database).filter(\\.$code == code).with(\\.$user).with(\\.$scopes).first()
                return authCode
            }
        
            public func loadTokens(on database: Database) async throws {
                try await self.$accessToken.load(on: database)
                try await self.$refreshToken.load(on: database)
            }
        
            public func setTokens(accessTokenID: UUID, refreshTokenID: UUID) {
                self.$accessToken.id = accessTokenID
                self.$refreshToken.id = refreshTokenID
            }
        
            /// Return revoked codes to delete.
            /// - Parameter database: Database.
            /// - Returns: The list of revoked or expired codes.
            public static func forDelete(on database: Database) async throws -> [AuthorizationCodes] {
                let revokedAuthCodes = try await AuthorizationCodes.query(on: database).group(.or) { group in
                    group.filter(\\.$isRevoked == true).filter(\\.$expired < Date())
                } .withDeleted().all()
                return revokedAuthCodes
            }
        
            public static func findByID(id: UUID, on database: Database) async throws -> AuthorizationCodes? {
                let authCode = try await AuthorizationCodes.query(on: database).filter(\\.$id == id).with(\\.$user).with(\\.$scopes).first()
                return authCode
            }
        }
        """, macros: ["AuthorizationCodeModel": AuthorizationCodeModelMacro.self])
    }
    
    // MARK: - AuthorizationCodeScopes
    func testAuthorizationCodeScope() throws {
        assertMacroExpansion("""
        @AuthorizationCodeScopeModel
        public final class AuthorizationCodeScopes: AuthorizationCodeScope {
            public static var schema: String = "oauth_authorization_code_scopes"
            public typealias AuthorizationCodeType = AuthorizationCodes
        }
        """, expandedSource: """
        public final class AuthorizationCodeScopes: AuthorizationCodeScope {
            public static var schema: String = "oauth_authorization_code_scopes"
            public typealias AuthorizationCodeType = AuthorizationCodes

            @ID(key: .id)
            public var id: UUID?

            @Parent(key: "authorization_code_id")
            public var authorizationCode: AuthorizationCodeType

            @Parent(key: "scope_id")
            public var scope: OAuthScopes

            public init(authorizationCodeID: AuthorizationCodeType.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$authorizationCode.id = authorizationCodeID
                self.$scope.id = scopeID
            }

            public init() {
        
            }
        }
        """,macros: ["AuthorizationCodeScopeModel": AuthorizationCodeScopeModelMacro.self])
    }
    
    // MARK: - RefreshTokens
    func testRefreshToken() throws {
        assertMacroExpansion("""
        @RefreshTokenModel
        public final class RefreshTokens: RefreshToken {
            public static var schema: String = "oauth_refresh_tokens"

            public typealias User = Users
            public typealias AccessTokenType = AccessTokens
        }
        """, expandedSource: """
        public final class RefreshTokens: RefreshToken {
            public static var schema: String = "oauth_refresh_tokens"

            public typealias User = Users
            public typealias AccessTokenType = AccessTokens

            @ID(key: .id)
            public var id: UUID?

            @Timestamp(key: "created", on: .create, format: .iso8601)
            public var created: Date?

            @Timestamp(key: "modified", on: .update, format: .iso8601)
            public var modified: Date?

            @Timestamp(key: "expired", on: .delete, format: .iso8601)
            public var expired: Date?

            @Field(key: "revoked")
            public var isRevoked: Bool

            @Field(key: "refresh_token")
            public var refreshToken: String

            @Parent(key: "access_token_id")
            public var accessToken: AccessTokenType

            @Parent(key: "user_id")
            public var user: User

            @Parent(key: "client_id")
            public var client: OAuthClients

            @Siblings(through: RefreshTokenScopes.self, from: \\.$refreshToken, to: \\.$scope)
            public var scopes: [OAuthScopes]

            public init(expired: Date, refreshToken: String, accessTokenID: UUID, userID: User.IDValue, clientID: UUID) {
                self.expired = expired
                self.isRevoked = false
                self.refreshToken = SHA512.hash(data: Data(refreshToken.utf8)).hexEncodedString()
                self.$accessToken.id = accessTokenID
                self.$user.id = userID
                self.$client.id = clientID
            }

            public init() {

            }
        
            public func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
        
            public static func queryRefreshToken(_ refreshToken: String, on database: Database) async throws -> RefreshTokens? {
                let refreshToken = try await RefreshTokens.query(on: database).filter(\\.$refreshToken == refreshToken).with(\\.$accessToken).with(\\.$user).with(\\.$client).with(\\.$scopes).first()
                return refreshToken
            }
        
            /// Return revoked tokens to delete.
            /// - Parameter database: Database.
            /// - Returns: The list of revoked or expired tokens.
            public static func forDelete(on database: Database) async throws -> [RefreshTokens] {
                let revokedRefreshTokens = try await RefreshTokens.query(on: database).group(.or) { group in
                    group.filter(\\.$isRevoked == true).filter(\\.$expired < Date())
                } .withDeleted().all()
                return revokedRefreshTokens
            }
        }
        """,macros: ["RefreshTokenModel": RefreshTokenModelMacro.self])
    }
    
    // MARK: RefreshTokenScopes
    func testRefreshTokenScope() throws {
        assertMacroExpansion("""
        @RefreshTokenScopeModel
        public final class RefreshTokenScopes: RefreshTokenScope {
            public static var schema: String = "oauth_refresh_token_scopes"

            public typealias RefreshTokenType = RefreshTokens
        }
        """, expandedSource: """
        public final class RefreshTokenScopes: RefreshTokenScope {
            public static var schema: String = "oauth_refresh_token_scopes"

            public typealias RefreshTokenType = RefreshTokens

            @ID(key: .id)
            public var id: UUID?

            @Parent(key: "refresh_token_id")
            public var refreshToken: RefreshTokenType

            @Parent(key: "scope_id")
            public var scope: OAuthScopes

            public init(refreshTokenID: RefreshTokenType.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$refreshToken.id = refreshTokenID
                self.$scope.id = scopeID
            }

            public init() {

            }
        }
        """,macros: ["RefreshTokenScopeModel": RefreshTokenScopeModelMacro.self])
    }
}

