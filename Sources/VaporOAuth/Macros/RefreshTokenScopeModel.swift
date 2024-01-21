//
//  RefreshTokenScopeModel.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/04.
//  


import Foundation
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro RefreshTokenScopeModel() = #externalMacro(module: "VaporOAuthMacros", type: "RefreshTokenScopeModelMacro")
