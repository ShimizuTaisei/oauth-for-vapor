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
}

struct AccessTokenResponse: Codable {
    var access_token: String
    var token_type: String
    var expires_in: Int
    var refresh_token: String?
    var scope: String?
}
