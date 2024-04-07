import NIOSSL
import VaporOAuth
import Fluent
import FluentMySQLDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(Users.sessionAuthenticator())

    #if DEBUG
    var tlsConfiguration = TLSConfiguration.makeClientConfiguration()
    tlsConfiguration.certificateVerification = .none
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tlsConfiguration: tlsConfiguration
    ), as: .mysql)
    #else
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .mysql)
    #endif


    app.views.use(.leaf)
    
//    app.migrations.add(CreateUsers())
    let oauthMigrationConfiguration = OAuthMigrationConfiguration(
        usersScheme: "users",
        authorizationCodesScheme: "oauth_authorization_codes",
        authorizationCodeScopesScheme: "oauth_authorization_code_scopes",
        accessTokensScheme: "oauth_access_tokens",
        accessTokenScopesScheme: "oauth_access_token_scopes",
        refreshTokensScheme: "oauth_refresh_tokens",
        refreshTokenScopesScheme: "oauth_refresh_token_scopes")
    
    app.migrations.add(CreateOAuthScopes())
    app.migrations.add(CreateOAuthClients())
    app.migrations.add(CreateOAuthAccessTokens(oauthMigrationConfiguration))
    app.migrations.add(CreateOAuthRefreshTokens(oauthMigrationConfiguration))
    app.migrations.add(CreateOAuthAuthorizationCodes(oauthMigrationConfiguration))
    app.migrations.add(CreateOAuthAccessTokenScopes(oauthMigrationConfiguration))
    app.migrations.add(CreateOAuthRefreshTokenScopes(oauthMigrationConfiguration))
    app.migrations.add(CreateOAuthAuthorizationCodeScopes(oauthMigrationConfiguration))
    
//    app.queues.schedule(OAuthCleanDatabase<AuthorizationCodes, AccessTokens, RefreshTokens>())
//        .daily()
//        .at(2, 0)
    
    app.queues.schedule(OAuthCleanDatabase<AuthorizationCodes, AccessTokens, RefreshTokens>())
        .minutely()
        .at(0)

    // register routes
    try routes(app)
}
