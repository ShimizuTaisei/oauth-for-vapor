//
//  AccessTokenAuthenticator.swift
//
//  
//  Created by Shimizu Taisei on 2024/02/04.
//  


import Foundation
import VaporOAuthMacros
import Vapor

@attached(extension, conformances: AsyncBearerAuthenticator, names: arbitrary)
public macro AccessTokenAuthenticator() = #externalMacro(module: "VaporOAuthMacros", type: "AccessTokenAuthenticatorMacro")
