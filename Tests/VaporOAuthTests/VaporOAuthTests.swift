@testable import Development
import XCTVapor

final class VaporOAuthTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        print(#function)
        app = Application(.testing)
        try await configure(app)
    }
    
    override func tearDown() async throws {
        print(#function)
        app.shutdown()
    }
    
    private func state() -> String {
        let stateArray = (0..<64).map { _ in
            UInt8.random(in: UInt8.min...UInt8.max)
        }
        let state = Data(stateArray).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        return state
    }
    
    // MARK: - Test GET /oauth/
    /// Test GET /oauth/ for redirect to /oauth/login/ successfuly when request contain correct parameters.
    func testGetAuthcodeWithCorrectRequest() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            XCTAssertEqual(location, "/oauth/login/")
        }
    }
    
    func testGetAuthCodeWithIncorrectResponseType() throws {
        let state = state()
        let path = "/oauth/?response_type=incorrect&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryParams = URLComponents(string: location)?.queryItems
            print(location)
            let error = try XCTUnwrap(queryParams?.first(where: { $0.name == "error" })?.value)
            XCTAssertEqual(error, "unsupported_response_type")
            print("Location: \(location)")
        }
    }
    
    func testGetAuthCodeWithIncorrectClientID() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=62243697-B259-1122-0000-9B8B2C83A9A7&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=teacher"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testGetAuthCodeWithIncorrectRedirecctURI() throws {
        let state = state()

        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://incorrect&state=\(state)&scope=test"

        // Test auth-code endpoint with correct request.
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testGetAuthCodeWithoutScope() throws {
        let state = state()

        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)"
        // Test auth-code endpoint with correct request.
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryParams = URLComponents(string: location)?.queryItems
            let error = try XCTUnwrap(queryParams?.first(where: { $0.name == "error" })?.value)
            XCTAssertEqual(error, "invalid_scope")
        }
    }
    
    func testGetAuthCodeWithIncorrectScope() throws {
        let state = state()

        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=incorrect"

        // Test auth-code endpoint with correct request.
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryParams = URLComponents(string: location)?.queryItems
            let error = try XCTUnwrap(queryParams?.first(where: { $0.name == "error" })?.value)
            XCTAssertEqual(error, "invalid_scope")
        }
    }
    
    func testGetAuthCodeWituoutState() throws {
        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&scope=test"

        // Test auth-code endpoint with correct request.
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            XCTAssertEqual(location, "/oauth/login/")
        }
    }
    
    // MARK: - Test POST /oauth/login/
    func testCorrectLoginAction() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        var cookie: HTTPCookies?
        
        try app.test(.GET, path) { res in
            cookie = res.headers.setCookie
        }
        
        var postLoginHeader = HTTPHeaders()
        postLoginHeader.cookie = cookie
        postLoginHeader.contentType = .urlEncodedForm
        
        let postLoginBody = ByteBuffer(string: "username=test&password=test")
        try app.test(.POST, "/oauth/login/",headers: postLoginHeader, body: postLoginBody) { res in
            XCTAssertEqual(res.status, .found)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryItems = URLComponents(string: location)?.queryItems
            let returnedState = try XCTUnwrap(queryItems?.first(where: { $0.name == "state" })?.value)
            XCTAssertEqual(returnedState, state)
            XCTAssertNotNil(queryItems?.first(where: { $0.name == "code" }))
        }
    }
    
    func testLoginActionWithIncorrectCredentials() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        var cookie: HTTPCookies?
        
        try app.test(.GET, path) { res in
            cookie = res.headers.setCookie
        }
        
        var postLoginHeader = HTTPHeaders()
        postLoginHeader.cookie = cookie
        postLoginHeader.contentType = .urlEncodedForm
        
        let postLoginBodyInvalidUsername = ByteBuffer(string: "username=invalid&password=test")
        try app.test(.POST, "/oauth/login/" ,headers: postLoginHeader, body: postLoginBodyInvalidUsername) { res in
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            print("Location: \(location)")
            XCTAssertEqual(res.status, .seeOther)
        }
        
        let postLoginBodyInvalidPassword = ByteBuffer(string: "username=test&password=invalid")
        try app.test(.POST, "/oauth/login/",headers: postLoginHeader, body: postLoginBodyInvalidPassword) { res in
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            print("Location: \(location)")
            XCTAssertEqual(res.status, .seeOther)
        }
    }
    
    // MARK: - Test /oauth/token/ with authorization code.
    func testAccessTokenWithCorrrectRequest() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        var cookie: HTTPCookies?
        
        try app.test(.GET, path) { res in
            cookie = res.headers.setCookie
        }
        
        var postLoginHeader = HTTPHeaders()
        postLoginHeader.cookie = cookie
        postLoginHeader.contentType = .urlEncodedForm
        
        let postLoginBody = ByteBuffer(string: "username=test&password=test")
        
        var authCode = ""
        try app.test(.POST, "/oauth/login/",headers: postLoginHeader, body: postLoginBody) { res in
            XCTAssertEqual(res.status, .found)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryItems = URLComponents(string: location)?.queryItems
            let returnedState = try XCTUnwrap(queryItems?.first(where: { $0.name == "state" })?.value)
            XCTAssertEqual(returnedState, state)
            authCode = try XCTUnwrap(queryItems?.first(where: { $0.name == "code" })?.value)
        }
        
        var postTokenHeader = HTTPHeaders()
        postTokenHeader.contentType = .urlEncodedForm
        let tokenRequestBody = ByteBuffer(string: "grant_type=authorization_code&code=\(authCode)&redirect_uri=shimizutaiseixcodetest://callback&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2")
        try app.test(.POST, "/oauth/token/", headers: postTokenHeader, body: tokenRequestBody) { res in
            XCTAssertEqual(res.status, .ok)
            let accessTokens = try JSONDecoder().decode(AccessTokenResponse.self, from: res.body)
            XCTAssertEqual(accessTokens.token_type, "bearer")
            XCTAssertNotNil(accessTokens.refresh_token)
        }
    }
    
    // MARK: - Test /oauth/token/ with refresh token
    func testRefreshTokenWithCorrectRequest() async throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        var cookie: HTTPCookies?
        
        try app.test(.GET, path) { res in
            cookie = res.headers.setCookie
        }
        
        var postLoginHeader = HTTPHeaders()
        postLoginHeader.cookie = cookie
        postLoginHeader.contentType = .urlEncodedForm
        
        let postLoginBody = ByteBuffer(string: "username=test&password=test")
        
        var authCode = ""
        try app.test(.POST, "/oauth/login/",headers: postLoginHeader, body: postLoginBody) { res in
            XCTAssertEqual(res.status, .found)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryItems = URLComponents(string: location)?.queryItems
            let returnedState = try XCTUnwrap(queryItems?.first(where: { $0.name == "state" })?.value)
            XCTAssertEqual(returnedState, state)
            authCode = try XCTUnwrap(queryItems?.first(where: { $0.name == "code" })?.value)
        }
        
        var postTokenHeader = HTTPHeaders()
        postTokenHeader.contentType = .urlEncodedForm
        let tokenRequestBody = ByteBuffer(string: "grant_type=authorization_code&code=\(authCode)&redirect_uri=shimizutaiseixcodetest://callback&client_id=67C70D9C-DE50-4A2B-8F0F-86E79607DFD2")
        
        var refreshToken = ""
        try app.test(.POST, "/oauth/token/", headers: postTokenHeader, body: tokenRequestBody) { res in
            XCTAssertEqual(res.status, .ok)
            let accessTokens = try JSONDecoder().decode(AccessTokenResponse.self, from: res.body)
            XCTAssertEqual(accessTokens.token_type, "bearer")
            refreshToken = try XCTUnwrap(accessTokens.refresh_token)
        }
        try await Task.sleep(for: .seconds(5))
        
        let refreshTokenRequestBody = ByteBuffer(string: "grant_type=refresh_token&refresh_token=\(refreshToken)")
        try app.test(.POST, "/oauth/token/", headers: postTokenHeader, body: refreshTokenRequestBody) { res in
            XCTAssertEqual(res.status, .ok)
            let accessTokens = try JSONDecoder().decode(AccessTokenResponse.self, from: res.body)
            XCTAssertEqual(accessTokens.token_type, "bearer")
            XCTAssertNotNil(accessTokens.refresh_token)
        }
    }
}

struct AccessTokenResponse: Codable {
    var access_token: String
    var token_type: String
    var expires_in: Int
    var refresh_token: String?
    var scope: String?
}
