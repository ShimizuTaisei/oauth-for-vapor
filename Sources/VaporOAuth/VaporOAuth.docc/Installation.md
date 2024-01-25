# Installation

Add oauth-for-vapor package to your project.

## Overview

You can add oauth-for-vapor package to your vapor project via Swift Package Manager.

### Add package dependencies

First, please add dependencies to Package.swift in your project.
```swift
let package = Package(
    ...,
    dependencies: [        
        ...,
        .package(url: "https://github.com/ShimizuTaisei/oauth-for-vapor.git", branch: "main")
    ],
)
```

Then, add dependencies to targets too.
```swift
let package = Package(
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                ...,
                .product(name: "VaporOAuth", package: "oauth-for-vapor"),
            ]
        ),
    ]
)
```

### Import to your project.
After adding dependencies, you can import this package.
```swift
import VaporOAuth
```
