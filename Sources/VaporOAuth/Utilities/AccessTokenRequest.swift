//
//  AccessTokenRequest.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/30.
//  


import Foundation
import Vapor

public struct AccessTokenRequest: Content {
    /// Grant Type on access token reqest.
    public var grant_type: String
}
