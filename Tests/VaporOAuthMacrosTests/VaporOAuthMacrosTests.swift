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
    func testAccessToken() throws {
        assertMacroExpansion("""
        @AccessTokenModel
        public final class AccessTokens: AccessToken {
            public static var schema: String = "oauth_access_tokens"
            public typealias User = Users
            public typealias AccessTokenScope = AccessTokenScopes
        }
        """, expandedSource: """
        public final class AccessTokens: AccessToken {
            public static var schema: String = "oauth_access_tokens"
            public typealias User = Users
            public typealias AccessTokenScope = AccessTokenScopes

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

            @Siblings(through: AccessTokenScope.self, from: \\.$accessToken, to: \\.$scope)
            public var scopes: [OAuthScopes]

            public init(expired: Date, accessToken: String, userID: User.IDValue, clientID: OAuthClients.IDValue) {
                self.expired = expired
                self.isRevoked = false
                self.accessToken = accessToken
                self.$user.id = userID
                self.$client.id = clientID
            }

            public init() {

            }
        }
        """
        , macros: ["AccessTokenModel": AccessTokenModelMacro.self])
    }
    
    func testAccesTokenScope() throws {
        assertMacroExpansion("""
        @AccessTokenScopeModel
        public final class AccessTokenScopes: AccessTokenScope {
            public static var schema: String = "oauth_access_token_scopes"
            public typealias AccessToken = AccessTokens
        }
        """, expandedSource: """
        public final class AccessTokenScopes: AccessTokenScope {
            public static var schema: String = "oauth_access_token_scopes"
            public typealias AccessToken = AccessTokens

            @ID(key: .id)
            public var id: UUID?

            @Parent(key: "access_token_id")
            public var accessToken: AccessToken

            @Parent(key: "scope_id")
            public var scope: OAuthScopes

            public init(accessTokenID: AccessToken.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$accessToken.id = accessTokenID
                self.$scope.id = scopeID
            }

            public init() {

            }
        }
        """,
        macros: ["AccessTokenScopeModel": AccesstokenScopeModelMacro.self])
    }
    
    func testAuthorizationCode() throws {
        assertMacroExpansion("""
        @AuthorizationCodeModel
        public final class AuthorizationCodes: AuthorizationCode {
            public static var schema: String = "oauth_authorization_codes"
            
            public typealias User = Users
            public typealias AccessToken = AccessTokens
            public typealias RefreshToken = RefreshTokens
        }
        """, expandedSource: """
        public final class AuthorizationCodes: AuthorizationCode {
            public static var schema: String = "oauth_authorization_codes"
            
            public typealias User = Users
            public typealias AccessToken = AccessTokens
            public typealias RefreshToken = RefreshTokens

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

            @Parent(key: "client_id")
            public var client: OAuthClients

            @Parent(key: "user_id")
            public var user: User

            @OptionalParent(key: "access_token_id")
            public var accessToken: AccessToken?

            @OptionalParent(key: "refresh_token_id")
            public var refreshToken: RefreshToken?

            @Siblings(through: AuthorizationCodeScopes.self, from: \\.$authorizationCode, to: \\.$scope)
            public var scopes: [OAuthScopes]

            public init(expired: Date, code: String, redirectURI: String, clientID: OAuthClients.IDValue, userID: User.IDValue) {
                self.expired = expired
                self.isRevoked = false
                self.isUsed = false
                self.code = code
                self.redirectURI = redirectURI
                self.$client.id = clientID
                self.$user.id = userID
            }

            public init() {

            }
        
            public func setScopes(_ scopes: [OAuthScopes], on database: Database) async throws {
                try await self.$scopes.attach(scopes, on: database)
            }
        }
        """, macros: ["AuthorizationCodeModel": AuthorizationCodeModelMacro.self])
    }
    
    func testAuthorizationCodeScope() throws {
        assertMacroExpansion("""
        @AuthorizationCodeScopeModel
        public final class AuthorizationCodeScopes: AuthorizationCodeScope {
            public static var schema: String = "oauth_authorization_code_scopes"
            public typealias AuthorizationCode = AuthorizationCodes
        }
        """, expandedSource: """
        public final class AuthorizationCodeScopes: AuthorizationCodeScope {
            public static var schema: String = "oauth_authorization_code_scopes"
            public typealias AuthorizationCode = AuthorizationCodes

            @ID(key: .id)
            public var id: UUID?

            @Parent(key: "authorization_code_id")
            public var authorizationCode: AuthorizationCode

            @Parent(key: "scope_id")
            public var scope: OAuthScopes

            public init(authorizationCodeID: AuthorizationCode.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$authorizationCode.id = authorizationCodeID
                self.$scope.id = scopeID
            }

            public init() {
        
            }
        }
        """,macros: ["AuthorizationCodeScopeModel": AuthorizationCodeScopeModelMacro.self])
    }
    
    func testRefreshToken() throws {
        assertMacroExpansion("""
        @RefreshTokenModel
        public final class RefreshTokens: RefreshToken {
            public static var schema: String = "oauth_refresh_tokens"

            public typealias User = Users
            public typealias AccessToken = AccessTokens
        }
        """, expandedSource: """
        public final class RefreshTokens: RefreshToken {
            public static var schema: String = "oauth_refresh_tokens"

            public typealias User = Users
            public typealias AccessToken = AccessTokens

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

            @Parent(key: "access_token")
            public var accessToken: AccessToken

            @Parent(key: "user_id")
            public var user: User

            @Parent(key: "client_id")
            public var client: OAuthClients

            @Siblings(through: RefreshTokenScopes.self, from: \\.$refreshToken, to: \\.$scope)
            public var scopes: [OAuthScopes]

            public init(expired: Date, refreshToken: String, accessToken: AccessToken.IDValue, userID: User.IDValue, clientID: OAuthClients.IDValue) {
                self.expired = expired
                self.isRevoked = false
                self.refreshToken = refreshToken
                self.$accessToken.id = accessToken
                self.$user.id = userID
                self.$client.id = clientID
            }

            public init() {

            }
        }
        """,macros: ["RefreshTokenModel": RefreshTokenModelMacro.self])
    }
    
    func testRefreshTokenScope() throws {
        assertMacroExpansion("""
        @RefreshTokenScopeModel
        public final class RefreshTokenScopes: RefreshTokenScope {
            public static var schema: String = "oauth_refresh_token_scopes"

            public typealias RefreshToken = RefreshTokens
        }
        """, expandedSource: """
        public final class RefreshTokenScopes: RefreshTokenScope {
            public static var schema: String = "oauth_refresh_token_scopes"

            public typealias RefreshToken = RefreshTokens

            @ID(key: .id)
            public var id: UUID?

            @Parent(key: "refresh_token_id")
            public var refreshToken: RefreshToken

            @Parent(key: "refresh_token_id")
            public var scope: OAuthScopes

            public init(refreshTokenID: RefreshToken.IDValue, scopeID: OAuthScopes.IDValue) {
                self.$refreshToken.id = refreshTokenID
                self.$scope.id = scopeID
            }

            public init() {

            }
        }
        """,macros: ["RefreshTokenScopeModel": RefreshTokenScopeModelMacro.self])
    }
}

