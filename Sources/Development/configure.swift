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
    
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateOAuthScopes())
    app.migrations.add(CreateOAuthClients())
    app.migrations.add(CreateOAuthAccessTokens(userTableName: "users", userTableIdFiled: "id"))
    app.migrations.add(CreateOAuthRefreshTokens(userTableName: "users", userTableIdField: "id"))
    app.migrations.add(CreateOAuthAuthorizationCodes(userTableName: "users", userTableIdFiled: "id"))
    app.migrations.add(CreateOAuthAccessTokenScopes())
    app.migrations.add(CreateOAuthRefreshTokenScopes())
    app.migrations.add(CreateOAuthAuthorizationCodeScopes())
    
//    app.queues.schedule(OAuthCleanDatabase<AuthorizationCodes, AccessTokens, RefreshTokens>())
//        .daily()
//        .at(2, 0)
    
    app.queues.schedule(OAuthCleanDatabase<AuthorizationCodes, AccessTokens, RefreshTokens>())
        .minutely()
        .at(0)

    // register routes
    try routes(app)
}
