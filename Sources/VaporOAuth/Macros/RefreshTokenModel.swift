//
//  RefreshTokenModel.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro RefreshTokenModel() = #externalMacro(module: "VaporOAuthMacros", type: "RefreshTokenModelMacro")
