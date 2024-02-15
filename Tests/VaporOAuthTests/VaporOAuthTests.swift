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
    
    private func codeVerifierAndCodeChallenge() -> (String, String) {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJEKLMNOPQRSTUVWXYZ0123456789"
        let codeVerifier = String((0..<64).map { _ in
            letters.randomElement()!
        })
        let codeChallenge = Data(SHA256.hash(data: codeVerifier.data(using: .ascii)!)).base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
        return (codeVerifier, codeChallenge)
    }
    
    // MARK: - Test POST /oauth/login/
    
    // Public {"client_id":"58414467-87FD-4AF0-AD6E-890B83DDB3E1", "client_secret":null}
    // Confidential {"client_id":"9FA5F092-5F66-4D0E-892E-511A722E885A","client_secret":"Bd_2OWMZQn0crXYUuY2Cl-Q4mfAq01CCoc2kWyDFMDf6SBnGDHQ2DQOWnbjLyplA4QMImDdvb7xUYiTpCyoM2w"}
    func testCorrectLoginAction() throws {
        let state = state()
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        let (codeVerifier, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        let tokenRequestBody = ByteBuffer(string: "grant_type=authorization_code&code=\(authCode)&redirect_uri=shimizutaiseixcodetest://callback&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&code_verifier=\(codeVerifier)")
        try app.test(.POST, "/oauth/token/", headers: postTokenHeader, body: tokenRequestBody) { res in
            XCTAssertEqual(res.status, .ok)
            let accessTokens = try JSONDecoder().decode(AccessTokenResponse.self, from: res.body)
            XCTAssertEqual(accessTokens.token_type, "bearer")
            XCTAssertNotNil(accessTokens.refresh_token)
        }
    }
    
    func testAccessTokenForConfidenialWithCorrectRequest() throws {
        let state = state()
        let (codeVerifier, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=9FA5F092-5F66-4D0E-892E-511A722E885A&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        postTokenHeader.basicAuthorization = BasicAuthorization(username: "9FA5F092-5F66-4D0E-892E-511A722E885A", password: "Bd_2OWMZQn0crXYUuY2Cl-Q4mfAq01CCoc2kWyDFMDf6SBnGDHQ2DQOWnbjLyplA4QMImDdvb7xUYiTpCyoM2w")
        let tokenRequestBody = ByteBuffer(string: "grant_type=authorization_code&code=\(authCode)&redirect_uri=shimizutaiseixcodetest://callback&client_id=9FA5F092-5F66-4D0E-892E-511A722E885A&code_verifier=\(codeVerifier)")
        try app.test(.POST, "/oauth/token/", headers: postTokenHeader, body: tokenRequestBody) { res in
            XCTAssertEqual(res.status, .ok)
            let accessTokens = try JSONDecoder().decode(AccessTokenResponse.self, from: res.body)
            XCTAssertEqual(accessTokens.token_type, "bearer")
            XCTAssertNotNil(accessTokens.refresh_token)
        }
    }
    
    func testAccessTokenForConfidenialWithoutClientAuthentication() throws {
        let state = state()
        let (codeVerifier, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=9FA5F092-5F66-4D0E-892E-511A722E885A&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        let tokenRequestBody = ByteBuffer(string: "grant_type=authorization_code&code=\(authCode)&redirect_uri=shimizutaiseixcodetest://callback&client_id=9FA5F092-5F66-4D0E-892E-511A722E885A&code_verifier=\(codeVerifier)")
        try app.test(.POST, "/oauth/token/", headers: postTokenHeader, body: tokenRequestBody) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    // MARK: - Test /oauth/token/ with refresh token
    func testRefreshTokenWithCorrectRequest() async throws {
        let state = state()
        let (codeVerifier, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        let tokenRequestBody = ByteBuffer(string: "grant_type=authorization_code&code=\(authCode)&redirect_uri=shimizutaiseixcodetest://callback&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&code_verifier=\(codeVerifier)")
        
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
