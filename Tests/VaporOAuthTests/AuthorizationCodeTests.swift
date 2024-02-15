//
//  AuthorizationCodeTests.swift
//
//  
//  Created by Shimizu Taisei on 2024/02/13.
//  


@testable import Development
import XCTVapor

final class AuthorizationCodeTests: XCTestCase {
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
    
    // MARK: - Test GET /oauth/
    /// Test GET /oauth/ for redirect to /oauth/login/ successfuly when request contain correct parameters.
    func testGetAuthcodeWithCorrectRequest() throws {
        let state = state()
        let (codeVerifier, codeChallenge) = codeVerifierAndCodeChallenge()
        let pathWithS256 = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
        
        let pathWithPlain = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeVerifier)&code_challenge_method=plain"
        
        try app.test(.GET, pathWithS256) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            XCTAssertEqual(location, "/oauth/login/")
        }
        
        try app.test(.GET, pathWithPlain) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            XCTAssertEqual(location, "/oauth/login/")
        }
    }
    
    func testGetAuthcodeWithoutPKCE() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryParams = URLComponents(string: location)?.queryItems
            let error = try XCTUnwrap(queryParams?.first(where: { $0.name == "error" })?.value)
            XCTAssertEqual(error, "invalid_request")
            print("Location: \(location)")
        }
    }
    
    func testGetAuthcodeWithoutCodeChallenge() throws {
        let state = state()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge_method=S256"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryParams = URLComponents(string: location)?.queryItems
            let error = try XCTUnwrap(queryParams?.first(where: { $0.name == "error" })?.value)
            XCTAssertEqual(error, "invalid_request")
            print("Location: \(location)")
        }
    }
    
    func testGetAuthcodeWithoutCodeChallengeMethod() throws {
        let state = state()
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            let queryParams = URLComponents(string: location)?.queryItems
            let error = try XCTUnwrap(queryParams?.first(where: { $0.name == "error" })?.value)
            XCTAssertEqual(error, "invalid_request")
            print("Location: \(location)")
        }
    }
    
    func testGetAuthCodeWithIncorrectResponseType() throws {
        let state = state()
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=incorrect&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
        
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
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=00000000-0000-0000-0000-000000000000&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"
        
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testGetAuthCodeWithIncorrectRedirecctURI() throws {
        let state = state()
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=incorrect://callback&state=\(state)&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"

        // Test auth-code endpoint with correct request.
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testGetAuthCodeWithoutScope() throws {
        let state = state()
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&code_challenge=\(codeChallenge)&code_challenge_method=S256"
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
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&state=\(state)&scope=incorrect&code_challenge=\(codeChallenge)&code_challenge_method=S256"

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
        let (_, codeChallenge) = codeVerifierAndCodeChallenge()
        let path = "/oauth/?response_type=code&client_id=58414467-87FD-4AF0-AD6E-890B83DDB3E1&redirect_uri=shimizutaiseixcodetest://callback&scope=test&code_challenge=\(codeChallenge)&code_challenge_method=S256"

        // Test auth-code endpoint with correct request.
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .seeOther)
            let location = try XCTUnwrap(res.headers.first(name: "Location"))
            XCTAssertEqual(location, "/oauth/login/")
        }
    }
}
