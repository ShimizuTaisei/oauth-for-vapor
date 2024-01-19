//
//  AuthorizationCodeUtility.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/10.
//  


import Foundation
import Vapor
import Fluent

public class AuthCodeUtility {
    public func validateAuthRequest(req: Request, redirectURI: String) async throws -> Response {
        let queryParams = try req.query.decode(AuthorizationRequest.self)
        guard let clientUUID = UUID(uuidString: queryParams.client_id) else {
            return try buildAuthCodeError(req: req, redirectURI: nil, isInvalidRedirectURI: true, state: queryParams.state, error: .invalidRequest, description: "Invalid client_id")
        }
        let client = try await OAuthClients.find(clientUUID, on: req.db)
        
        // Check whether redirect_uri is correct.
        guard let uri = client?.redirectURIs.first(where: { $0 == queryParams.redirect_uri }) else {
            return try buildAuthCodeError(req: req, redirectURI: nil, isInvalidRedirectURI: true, state: queryParams.state, error: .invalidRequest, description: "Invalid redirect_uri.")
        }
        
        // Check whether response_type is "code"
        guard queryParams.response_type == "code" else {
            return try buildAuthCodeError(req: req, redirectURI: queryParams.redirect_uri, isInvalidRedirectURI: false, state: queryParams.state, error: .unsupportedResponseType, description: "The \"response_type\" must be set to \"code\".")
        }
        
        let scopeStrings = queryParams.scope?.components(separatedBy: " ") ?? []
        guard let scopes = try? await OAuthScopes.query(on: req.db).filter(\.$name ~~ scopeStrings).all() else {
            return try buildAuthCodeError(req: req, redirectURI: queryParams.redirect_uri, isInvalidRedirectURI: false, state: queryParams.state, error: .invalidScope, description: "Not found scope (DB query failed).")
        }
        
        guard scopes.count > 0 else {
            return try buildAuthCodeError(req: req, redirectURI: queryParams.redirect_uri, isInvalidRedirectURI: false, state: queryParams.state, error: .invalidScope, description: "Not found scope (scope count is 0).")
        }
        
        req.session.data["response_type"] = queryParams.response_type
        req.session.data["client_id"] = queryParams.client_id
        req.session.data["redirect_uri"] = queryParams.redirect_uri
        req.session.data["scope"] = queryParams.scope
        req.session.data["state"] = queryParams.state
        
        return req.redirect(to: redirectURI, redirectType: .normal)
    }
    
    private func buildAuthCodeError(req: Request, statusCode: HTTPResponseStatus = .badRequest, redirectURI: String?,
                                    isInvalidRedirectURI: Bool, state: String?, error: AuthorizationCodeError, description: String? = nil, errorURI: String? = nil) throws -> Response {
        if isInvalidRedirectURI {
            throw Abort(.badRequest, reason: description ?? "Missing or invalid redirect_uri")
        } else {
            let errorObject = AuthorizationCodeErrorResponse(error: error.rawValue, error_description: description, error_uri: errorURI, state: state)
            let queryString = try URLEncodedFormEncoder().encode(errorObject)
            if let redirectURI = redirectURI {
                return req.redirect(to: "\(redirectURI)/\(queryString)")
            } else {
                throw Abort(.internalServerError, reason: "Error at redirection")
            }
        }
    }
}

struct AuthorizationRequest: Content {
    var response_type: String
    var client_id: String
    var redirect_uri: String?
    var scope: String?
    var state: String?
}

struct AccessTokenRequest: Content {
    var grant_type: String
}

struct AccessTokenFromAuthorizationCodeRequest: Content {
    var grant_type: String
    var code: String
    var redirect_uri: String
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


struct AuthorizationCodeErrorResponse: Content {
    var error: String
    var error_description: String?
    var error_uri: String?
    var state: String?
}

enum AuthorizationCodeError: String {
    case invalidRequest = "invalid_request"
    case unauthorizedClient = "unauthorized_client"
    case accessDenied = "access_denied"
    case unsupportedResponseType = "unsupported_response_type"
    case invalidScope = "invalid_scope"
    case serverError = "server_error"
    case temporarilyUnavailable = "temporarily_unavailable"
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
