//
//  AccessTokenAuthenticator.swift
//
//  
//  Created by Shimizu Taisei on 2024/02/03.
//  


import Foundation
import Vapor

public protocol TokenAuthenticator: AsyncBearerAuthenticator {
    associatedtype AccessTokenType: AccessToken
}


