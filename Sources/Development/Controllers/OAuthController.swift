//
//  OAuthController.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/21.
//  


import Foundation
import Vapor
import Fluent
import VaporOAuth

struct OAuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let oauth = routes.grouped("oauth")
        let sessionAuth = oauth.grouped(Users.sessionAuthenticator())
        let credentialAuth = oauth.grouped(Users.credentialsAuthenticator())
        
        sessionAuth.get(use: getAuthTop(req:))
        sessionAuth.get("login", use: getLoginForm(req:))
        credentialAuth.post("login", use: postLoginForm(req:))
        oauth.post("token", use: postTokenEndpoint(req:))
    }
    
    // MARK: - GET /oauth/
    func getAuthTop(req: Request) async throws -> Response {
        return try await AuthCodeUtility().validateAuthRequest(req: req, redirectURI: "/oauth/login/")
    }
    
    // MARK: - GET /oauth/login/
    func getLoginForm(req: Request) async throws -> View {
        return try await req.view.render("loginForm", ["action": "/oauth/login/"])
    }
    
    // MARK: - POST /oauth/login/
    func postLoginForm(req: Request) async throws -> Response {
        do {
            let _ = try req.auth.require(Users.self)
        } catch {
            return req.redirect(to: "/oauth/login/", redirectType: .normal)
        }
        return try await AuthCodeUtility().issueAuthCode(req: req, type: AuthorizationCodes.self)
    }
    
    // MARK: - POST /oauth/token/
    func postTokenEndpoint(req: Request) async throws -> Response {
        let grantType = try req.content.decode(AccessTokenRequest.self).grant_type
        switch grantType {
        case "authorization_code":
            return try await AccessTokenUtility().accessTokenFromAuthCode(req: req, authCode: AuthorizationCodes.self, accessToken: AccessTokens.self, refreshToken: RefreshTokens.self)
            
        case "refresh_token":
            return try await AccessTokenUtility().accessTokenFromRefreshToken(req: req, accessToken: AccessTokens.self, refreshToken: RefreshTokens.self)
            
        default:
            throw Abort(.badRequest, reason: "Unknown grant_type.")
        }
    }
}

struct AccessTokenRequest: Content {
    var grant_type: String
}
