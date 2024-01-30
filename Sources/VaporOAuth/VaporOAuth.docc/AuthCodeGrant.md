# Adding Authorization Code Grant to Your Project

Adding Authorization Code Grant to your project.

## Overview

You can add authorization code grant with following steps.

### Define models
You have to define models to store OAuth data(such as access-token).
To support authorization code grant, create models which conform to following protocols.
* <doc:AuthorizationCode>
* <doc:AuthorizationCodeScope>
* <doc:AccessToken>
* <doc:AccessTokenScope>
* <doc:RefreshToken>
* <doc:RefreshTokenScope>

And you can use macros to implement properties required for protocol conformation. <br>
Following macros are available.
* [@AuthorizationCodeModel](<doc:AuthorizationCodeModel()>)
* [@AuthorizationCodeScopeModel](<doc:AuthorizationCodeScopeModel()>)
* [@AccessTokenModel](<doc:AccessTokenModel()>)
* [@AccessTokenScopeModel](<doc:AccessTokenScopeModel()>)
* [@RefreshTokenModel](<doc:RefreshTokenModel()>)
* [@RefreshTokenScopeModel](<doc:RefreshTokenScopeModel()>)

Then, implement `var schema` and `typealias`.
```swift
@AccessTokenModel
public final class AccessTokens: AccessToken {
    public static var schema: String = "oauth_access_tokens"
    public typealias User = Users  // Set your user table model.
    public typealias AccessTokenScopeType = AccessTokenScopes
}
```

### Add Migrations
Next, you need to create tables on your database.<br> 
Following migration files are available.
* <doc:CreateOAuthAuthorizationCodes>
* <doc:CreateOAuthAuthorizationCodeScopes>
* <doc:CreateOAuthAccessTokens>
* <doc:CreateOAuthAccessTokenScopes>
* <doc:CreateOAuthRefreshTokens>
* <doc:CreateOAuthRefreshTokenScopes>

You should add these migrations to configure.swift according to the following order because the tables refer each other.
```swift
app.migrations.add(CreateUsers())
app.migrations.add(CreateOAuthScopes())
app.migrations.add(CreateOAuthClients())
app.migrations.add(CreateOAuthAccessTokens(userTableName: "users", userTableIdFiled: "id"))
app.migrations.add(CreateOAuthRefreshTokens(userTableName: "users", userTableIdField: "id"))
app.migrations.add(CreateOAuthAuthorizationCodes(userTableName: "users", userTableIdFiled: "id"))
app.migrations.add(CreateOAuthAccessTokenScopes())
app.migrations.add(CreateOAuthRefreshTokenScopes())
app.migrations.add(CreateOAuthAuthorizationCodeScopes())
```

### Implement Endpoints
After defining model class and creating table on database, implement endpoints.
<doc:AuthCodeUtility> and <doc:AccessTokenUtility> help you when implement.
Following codes show you how to use these class in controller(it conforms to RouteCollection).


The function ``AuthCodeUtility/validateAuthRequest(req:redirectURI:)`` validates authorization code request.
If the request is valid, it redirects user for authentication (e.g. login form).
```swift
// MARK: - GET /oauth/
func getAuthTop(req: Request) async throws -> Response {
    return try await AuthCodeUtility().validateAuthRequest(req: req, redirectURI: "/oauth/login/")
}
```

After getting user authorization, call ``AuthCodeUtility/issueAuthCode(req:type:)`` to issue authorization code.
This function checks whether user is authenticated
```swift
// MARK: - POST /oauth/authorization/
func postLoginForm(req: Request) async throws -> Response {
    return try await AuthCodeUtility().issueAuthCode(req: req, type: AuthorizationCodes.self)
}
```

Finaly, implement the token endpoint.
In this example, It was created the endpoint "/oauth/token/" to issue and refresh access token.
The request is switched based on its request data, "grant_type". 
You can get "grant_type" by decoding with ``AccessTokenRequest``.

To issue access token based on authorization code, call  ``AccessTokenUtility/accessTokenFromAuthCode(req:authCode:accessToken:refreshToken:)``.
To refresh access token based on refresh token, call ``AccessTokenUtility/accessTokenFromRefreshToken(req:accessToken:refreshToken:)``
These function needs argument which specify the type of access/refresh token. 
```swift
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
```
