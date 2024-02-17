//
//  File.swift
//  
//  
//  Created by Shimizu Taisei on 2024/02/17.
//  


import Foundation
import Vapor
import Fluent
import Queues

public struct OAuthCleanDatabase<AuthorizationCodes: AuthorizationCode,
                            Accesstokens: AccessToken,
                            Refreshtokens: RefreshToken>: AsyncScheduledJob {
    public init() {}
//
    public func run(context: Queues.QueueContext) async throws {
        print("Clean database...")
        
        let revokedAuthCodes = try await AuthorizationCodes.forDelete(on: context.application.db)
        for revokedAuthCode in revokedAuthCodes {
            try await revokedAuthCode.delete(force: true, on: context.application.db)
        }
        
        let revokedAccessTokens = try await Accesstokens.forDelete(on: context.application.db)
        for revokedAccessToken in revokedAccessTokens {
            try await revokedAccessToken.delete(force: true, on: context.application.db)
        }
        
        let revokedRefreshTokens = try await Refreshtokens.forDelete(on: context.application.db)
        for revokedRefreshToken in revokedRefreshTokens {
            try await revokedRefreshToken.delete(force: true, on: context.application.db)
        }
    }
}
