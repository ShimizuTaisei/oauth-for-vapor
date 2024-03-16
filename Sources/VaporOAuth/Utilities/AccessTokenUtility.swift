//
//  AccessTokenUtility.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/20.
//  


import Foundation
import Vapor
import Fluent
import Crypto

public class AccessTokenUtility {
    public init() {}
    
    /// Issue access token based on authorization code.
    /// - Parameters:
    ///   - req: The request object from route function.
    ///   - authCode: The type of authorization-code model.
    ///   - accessToken: The type of access-token model.
    ///   - refreshToken: The type of refresh-token model.
    /// - Returns: The response with access token.
    public func accessTokenFromAuthCode
    <AuthCodes: AuthorizationCode, AccessTokens: AccessToken, RefreshTokens: RefreshToken>
    (req: Request, authCode: AuthCodes.Type, accessToken: AccessTokens.Type, refreshToken: RefreshTokens.Type) async throws -> Response {
        let requestParams = try req.content.decode(AccessTokenFromAuthorizationCodeRequest.self)
        
        // Authenticate client if client type is confidential.
        let clientID = UUID(uuidString: requestParams.client_id)
        guard let client = try await OAuthClients.find(clientID, on: req.db) else {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidRequest, description: "Invalid client_id")
        }
        if client.isConfidentialClient {
            try req.auth.require(OAuthClients.self)
        }
        
        // Extract auth code ID and code's body.
        guard let codeData = requestParams.code.base64URLDecoded(),
              let codeWithID = String(data: codeData, encoding: .utf8) else {
            throw Abort(.badRequest)
        }
        let codeAndID = codeWithID.components(separatedBy: ":")
        guard let id = UUID(uuidString: codeAndID[0]) else { throw Abort(.badRequest) }
        let code = codeAndID[1]
        
        // Find auth code on database by id.
        guard let authCode = try await AuthCodes.findByID(id: id, on: req.db) else {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidGrant, description: "Missing or invalid code.")
        }
        
        guard try Bcrypt.verify(code, created: authCode.code) else {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidGrant, description: "Invalid code.")
        }
        
        // Check code_challenge
        if let codeVerifier = requestParams.code_verifier, let codeVerifierData = codeVerifier.data(using: .ascii) {
            let codeChallenge: String
            switch authCode.codeChallengeMethod {
            case "plain":
                codeChallenge = codeVerifier
            case "S256":
                codeChallenge = Data(SHA256.hash(data: codeVerifierData)).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
            default:
                throw Abort(.internalServerError)
            }
            
            guard codeChallenge == authCode.codeChallenge else {
                return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidGrant, description: "Invalid code_verifier")
            }
        } else {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidRequest, description: "Request must contain code_verifier")
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
        
        guard let _ = client.redirectURIs.first(where: { $0 == requestParams.redirect_uri }) else {
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
    
    /// Issue access-token based on refresh-token.
    /// - Parameters:
    ///   - req: The request object from route function.
    ///   - accessToken: The type of access-token model.
    ///   - refreshToken: The type of refresh-token model.
    /// - Returns: The response with access-token.
    public func accessTokenFromRefreshToken<AccessTokens: AccessToken, RefreshTokens: RefreshToken>(req: Request, accessToken: AccessTokens.Type, refreshToken: RefreshTokens.Type) async throws -> Response {
        let requestParams = try req.content.decode(AccessTokenFromRefreshTokenRequest.self)
        
        // Extract refresh token ID and token's body.
        guard let refreshTokenData = requestParams.refresh_token.base64URLDecoded(),
              let refreshTokenWithID = String(data: refreshTokenData, encoding: .utf8) else {
            throw Abort(.badRequest)
        }
        let refreshTokenAndID = refreshTokenWithID.components(separatedBy: ":")
        guard let refreshTokenID = UUID(uuidString: refreshTokenAndID[0]) else {
            throw Abort(.badRequest)
        }
        let givenRefreshToken = refreshTokenAndID[1]
        
        // Find refresh token on database by id.
        guard let refreshToken = try await RefreshTokens.findByID(id: refreshTokenID, on: req.db) else {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidRequest, description: "Invalid refresh_token")
        }
        
        guard try Bcrypt.verify(givenRefreshToken, created: refreshToken.refreshToken) else {
            return try accessTokenError(req: req, statusCode: .unauthorized, error: .invalidRequest, description: "Invalid refresh token.")
        }
        
        if refreshToken.isRevoked {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidRequest, description: "refresh_token is revoked.")
        }
        if Date() >= refreshToken.expired ?? Date() {
            return try accessTokenError(req: req, statusCode: .badRequest, error: .invalidRequest, description: "refresh_token is already expired.")
        }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        let (response, _, _): (AccessTokenResponse, AccessTokens, RefreshTokens) = try await buildAccessTokens(req: req, userID: refreshToken.user.requireID() as! AccessTokens.User.IDValue, clientID: refreshToken.client.requireID(), scopes: refreshToken.scopes)
        
        // Revoke previous access token.
        if let oldAccessToken = refreshToken.accessToken {
            oldAccessToken.isRevoked = true
            oldAccessToken.expired = Date()
            try await oldAccessToken.save(on: req.db)
        }

        // Revoke previous refresh token.
        refreshToken.isRevoked = true
        refreshToken.expired = Date()
        try await refreshToken.save(on: req.db)
        
        let headers = HTTPHeaders([("Content-Type", "application/json; charset=utf-8")])
        let body = try jsonEncoder.encode(response)
        return Response(status: .ok, headers: headers, body: .init(data: body))
    }
    
    private func buildAccessTokens
    <AccessTokens: AccessToken, RefreshTokens: RefreshToken>
    (req: Request, userID: AccessTokens.User.IDValue, clientID: OAuthClients.IDValue, scopes: [OAuthScopes]) async throws -> (AccessTokenResponse, AccessTokens, RefreshTokens) {
        let (oauthAccessToken, rawAccessToken, expiresIn): (AccessTokens, String, Int) = try generateAccessToken(userID: userID, clientID: clientID)
        try await oauthAccessToken.save(on: req.db)
        
        let accessTokenWithID = "\(oauthAccessToken.id!.uuidString):\(rawAccessToken)"
        let accessToken = Data(accessTokenWithID.utf8).base64URLEncodedString()
        
        let (oauthRefreshToken, rawRefreshToken): (RefreshTokens, String) = try generateRefreshToken(accessToken: oauthAccessToken, userID: userID, clientID: clientID)
        try await oauthRefreshToken.save(on: req.db)
        
        let refreshTokenWithID = "\(oauthRefreshToken.id!.uuidString):\(rawRefreshToken)"
        let refreshToken = Data(refreshTokenWithID.utf8).base64URLEncodedString()
        
        try await oauthAccessToken.setScope(scopes, on: req.db)
        try await oauthRefreshToken.setScopes(scopes, on: req.db)
        
        try await oauthAccessToken.save(on: req.db)
        try await oauthRefreshToken.save(on: req.db)
        
        var scopeStrings = ""
        for scope in scopes {
            scopeStrings += "\(scope.name) "
        }
        let accessTokenResponse = AccessTokenResponse(access_token: accessToken, token_type: "bearer", expires_in: expiresIn, refresh_token: refreshToken, scope: scopeStrings)
        return (accessTokenResponse, oauthAccessToken, oauthRefreshToken)
    }
    
    private func generateAccessToken<AccessTokens: AccessToken>(userID: AccessTokens.User.IDValue,clientID: UUID) throws -> (AccessTokens, String, Int) {
        let accessToken = Data([UInt8].random(count: 64)).base64URLEncodedString()
        let expiresIn = 60 * 60
        let expired = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        let oauthAccessToken = try AccessTokens(expired: expired, accessToken: accessToken, userID: userID, clientID: clientID)
        return (oauthAccessToken, accessToken, expiresIn)
    }
    
    private func generateRefreshToken<AccessTokens: AccessToken, RefreshTokens: RefreshToken>
    (accessToken: AccessTokens, userID: AccessTokens.User.IDValue, clientID: UUID) throws -> (RefreshTokens, String) {
        let refreshToken = Data([UInt8].random(count: 64)).base64URLEncodedString()
        let expiresIn = 60 * 60 * 24 * 7
        let expired = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        let oauthRefreshToken = try RefreshTokens(expired: expired, refreshToken: refreshToken, accessTokenID: accessToken.requireID(), userID: userID as! RefreshTokens.User.IDValue, clientID: clientID)
        return (oauthRefreshToken, refreshToken)
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

struct AccessTokenFromAuthorizationCodeRequest: Content {
    var grant_type: String
    var code: String
    var redirect_uri: String
    var code_verifier: String?
    var client_id: String
}

struct AccessTokenFromRefreshTokenRequest: Content {
    var grant_type: String
    var refresh_token: String
    var scope: String?
}

struct AccessTokenResponse: Content {
    var access_token: String
    var token_type: String
    var expires_in: Int
    var refresh_token: String?
    var scope: String?
}

struct AccessTokenErrorResponse: Content {
    var error: String
    var error_description: String?
    var error_uri: String?
}

enum AccessTokenError: String {
    case invalidRequest = "invalid_request"
    case invalidClient = "invalid_client"
    case invalidGrant = "invalid_grant"
    case unauthorizedClient = "unauthorized_client"
    case unsupportedGrantType = "unsupported_grant_type"
    case invalidScope = "invalid_scope"
}
