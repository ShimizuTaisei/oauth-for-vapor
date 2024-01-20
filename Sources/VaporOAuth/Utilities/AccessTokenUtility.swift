//
//  AccessTokenUtility.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/20.
//  


import Foundation
import Vapor
import Fluent

public class AccessTokenUtility {
    public func accessTokenFromAuthCode
    <AuthCodes: AuthorizationCode, AccessTokens: AccessToken, RefreshTokens: RefreshToken>
    (req: Request, authCode: AuthCodes.Type, accessToken: AccessTokens.Type, refreshToken: RefreshTokens.Type) async throws -> Response {
        let requestParams = try req.content.decode(AccessTokenFromAuthorizationCodeRequest.self)
        guard let authCode = try await AuthCodes.queryByAuthCode(on: req.db, code: requestParams.code) else {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidGrant, description: "Missing or invalid code.")
        }
        
        if authCode.isUsed {
            // Revoke access tokens which issued based on the auth code
            try await authCode.loadTokens(on: req.db)
            let accessToken = authCode.accessToken
            accessToken?.isRevoked = true
            accessToken?.expired = Date()
            try await accessToken?.save(on: req.db)
            
            // Revoke refresh token too.
            let refreshToken = authCode.refreshToken
            refreshToken?.isRevoked = true
            refreshToken?.expired = Date()
            try await refreshToken?.save(on: req.db)
            
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidGrant, description: "Provided code is already used.")
        }
        authCode.isUsed = true
        try await authCode.save(on: req.db)
        
        if authCode.isRevoked {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidGrant, description: "Provided code was revoked.")
        }
        if Date() >= authCode.expired ?? Date() {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidGrant, description: "Provided code was expired.")
        }
        
        guard let clientUUID = UUID(uuidString: requestParams.client_id) else {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidClient, description: "Invalid client_id")
        }
        guard let client = try await OAuthClients.find(clientUUID, on: req.db) else {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidClient, description: "Invalid client_id")
        }
        
        guard let uri = client.redirectURIs.first(where: { $0 == requestParams.redirect_uri }) else {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidGrant, description: "Invalid redirect_uri.")
        }
        
        guard authCode.redirectURI == requestParams.redirect_uri else {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidGrant, description: "Invalid redirect_uri.")
        }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        let (response, accessToken, refreshToken): (AccessTokenResponse, AccessTokens, RefreshTokens) = try await buildAccessTokens(req: req, userID: authCode.user.requireID() as! AccessTokens.User.IDValue, clientID: client.requireID(), scopes: authCode.scopes)
        try authCode.setTokens(accessTokenID: accessToken.requireID(), refreshTokenID: refreshToken.requireID())
        try await authCode.save(on: req.db)
        
        let headers = HTTPHeaders([("Content-Type", "application/json; charset=utf-8")])
        let body = try jsonEncoder.encode(response)
        return Response(status: .ok, headers: headers, body: .init(data: body))
    }
    
    private func buildAccessTokens
    <AccessTokens: AccessToken, RefreshTokens: RefreshToken>
    (req: Request, userID: AccessTokens.User.IDValue, clientID: OAuthClients.IDValue, scopes: [OAuthScopes]) async throws -> (AccessTokenResponse, AccessTokens, RefreshTokens) {
        let (accessToken, expiresIn): (AccessTokens, Int) = generateAccessToken(userID: userID, clientID: clientID)
        try await accessToken.save(on: req.db)
        
        let refreshToken: RefreshTokens = try generateRefreshToken(accessToken: accessToken, userID: userID, clientID: clientID)
        try await refreshToken.save(on: req.db)
        
        try await accessToken.setScope(scopes, on: req.db)
        try await refreshToken.setScopes(scopes, on: req.db)
        
        try await accessToken.save(on: req.db)
        try await refreshToken.save(on: req.db)
        
        var scopeStrings = ""
        for scope in scopes {
            scopeStrings += "\(scope.name) "
        }
        let accessTokenResponse = AccessTokenResponse(access_token: accessToken.accessToken, token_type: "bearer", expires_in: expiresIn, refresh_token: refreshToken.refreshToken, scope: scopeStrings)
        return (accessTokenResponse, accessToken, refreshToken)
    }
    
    private func generateAccessToken<AccessTokens: AccessToken>(userID: AccessTokens.User.IDValue,clientID: UUID) -> (AccessTokens, Int) {
        let accessToken = [UInt8].random(count: 64).base64.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        let expiresIn = 60 * 60
        let expired = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        let oauthAccessToken = AccessTokens(expired: expired, accessToken: accessToken, userID: userID, clientID: clientID)
        return (oauthAccessToken, expiresIn)
    }
    
    private func generateRefreshToken<AccessTokens: AccessToken, RefreshTokens: RefreshToken>
    (accessToken: AccessTokens, userID: AccessTokens.User.IDValue, clientID: UUID) throws -> RefreshTokens {
        let refreshToken = [UInt8].random(count: 64).base64.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        let expiresIn = 60 * 60 * 24 * 7
        let expired = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        let oauthRefreshToken = try RefreshTokens(expired: expired, refreshToken: refreshToken, accessTokenID: accessToken.requireID(), userID: userID as! RefreshTokens.User.IDValue, clientID: clientID)
        return oauthRefreshToken
    }
    
    private func accessTokenError(req: Request, statusCode: HTTPResponseStatus, error: AccessTokenError, description: String?, errorURI: String? = nil) throws -> Response {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let accessTokenError = AccessTokenErrorResponse(error: error.rawValue, error_description: description, error_uri: errorURI)
        let headers = HTTPHeaders([("Content-Type", "application/json; charset=utf-8")])
        let body = try jsonEncoder.encode(accessTokenError)
        return Response(status: statusCode, headers: headers, body: .init(data: body))
    }
}
