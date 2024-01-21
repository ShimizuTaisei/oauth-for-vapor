import Fluent
import Vapor
import VaporOAuth

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    try app.register(collection: OAuthClientsController())
    try app.register(collection: OAuthScopesController())
}
