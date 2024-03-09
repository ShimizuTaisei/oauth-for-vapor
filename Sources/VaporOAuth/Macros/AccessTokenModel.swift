//
//  AccessTokenModel.swift
//
//  
//  Created by Shimizu Taisei on 2024/01/03.
//  

import Foundation
import VaporOAuthMacros

@attached(member, names: arbitrary)
public macro AccessTokenModel() = #externalMacro(module: "VaporOAuthMacros", type: "AccessTokenModelMacro")

