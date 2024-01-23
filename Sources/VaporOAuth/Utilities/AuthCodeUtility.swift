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
    public init() {}
    
    /// Validate authorization code request and create response for redirection to login form.
    /// - Parameters:
    ///   - req: Request object from route function.
    ///   - redirectURI: The location where to redirect after request validation (such as login form).
    /// - Returns: Redirect response.
    public func validateAuthRequest(req: Request, redirectURI: String) async throws -> Response {
        let queryParams = try req.query.decode(AuthorizationRequest.self)
        guard let clientUUID = UUID(uuidString: queryParams.client_id) else {
            return try buildAuthCodeError(req: req, redirectURI: nil, isInvalidRedirectURI: true, state: queryParams.state, error: .invalidRequest, description: "Invalid client_id")
        }
        let client = try await OAuthClients.find(clientUUID, on: req.db)
        
        // Check whether redirect_uri is correct.
        guard let _ = client?.redirectURIs.first(where: { $0 == queryParams.redirect_uri }) else {
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
    
    /// Issue authorization code after login.
    /// - Parameter req: Request object from route function.
    /// - Returns: The resonse which redirect user to given redirect-uri.
    public func issueAuthCode<AuthCodes: AuthorizationCode>(req: Request, type: AuthCodes.Type) async throws -> Response {
        let state = req.session.data["state"]
        
        guard let redirectURI = req.session.data["redirect_uri"] else {
            return try buildAuthCodeError(req: req, redirectURI: nil, isInvalidRedirectURI: true, state: state, error: .invalidRequest, description: "Invalid redirect_uri")
        }
        
        guard let clientID = req.session.data["client_id"] else {
            return try buildAuthCodeError(req: req, redirectURI: redirectURI, isInvalidRedirectURI: false, state: state, error: .invalidRequest, description: "Invalid client_id")
        }
        let clientUUID = UUID(uuidString: clientID)
        guard let client = try await OAuthClients.find(clientUUID, on: req.db) else {
            return try buildAuthCodeError(req: req, redirectURI: redirectURI, isInvalidRedirectURI: false, state: state, error: .invalidRequest, description: "Invalid client_id")
        }
        
        let user = try req.auth.require(AuthCodes.User.self)
        
        let scopeStrings = req.session.data["scope"]?.components(separatedBy: " ") ?? []
        guard let scopes = try? await OAuthScopes.query(on: req.db).filter(\.$name ~~ scopeStrings).all() else {
            return try buildAuthCodeError(req: req, redirectURI: redirectURI, isInvalidRedirectURI: false, state: state, error: .invalidScope, description: "Not found scope")
        }
        guard scopes.count > 0 else {
            return try buildAuthCodeError(req: req, redirectURI: redirectURI, isInvalidRedirectURI: false, state: state, error: .invalidScope, description: "Not found scope")
        }
        
        let authorizationCode: AuthCodes = try generateAuthorizationCode(userID: user.requireID(), clientID: client.requireID(), redirectURI: redirectURI)
        try await authorizationCode.save(on: req.db)
        try await authorizationCode.setScopes(scopes, on: req.db)
        
        let authCodeResponse = AuthCodeResponse(code: authorizationCode.code, state: state)
        let queryParams = try URLEncodedFormEncoder().encode(authCodeResponse)
        let httpResponse = req.redirect(to: "\(redirectURI)?\(queryParams)")
        httpResponse.status = .found
        return httpResponse
    }
    
    struct AuthCodeResponse: Content {
        var code: String
        var state: String?
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
    
    private func generateAuthorizationCode<AuthCodes: AuthorizationCode>(userID: AuthCodes.User.IDValue, clientID: OAuthClients.IDValue, redirectURI: String) throws -> AuthCodes {
        let code = [UInt8].random(count: 64).base64.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        guard let expiresDate = Calendar.current.date(byAdding: .minute, value: 3, to: Date()) else {
            throw Abort(.internalServerError, reason: "Couldn't get expires date.")
        }
        let authCodes = AuthCodes(expired: expiresDate, code: code, redirectURI: redirectURI, clientID: clientID, userID: userID)
        return authCodes
    }
    
    
}

struct AuthorizationRequest: Content {
    var response_type: String
    var client_id: String
    var redirect_uri: String?
    var scope: String?
    var state: String?
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
