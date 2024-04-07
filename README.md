# OAuth for Vapor
## Warning
This is a framework under development. This framework may contain bugs or security issues.
You should check codes before you import it to your project.

If you find a bug that needs to be fixed, I'll be glad if you let me know.

## Overview
Add the OAuth authorization function to the existing Vapor project. We will issue access tokens according to the Authorization Code Grant of [OAuth 2.0(RFC 6749)](https://datatracker.ietf.org/doc/html/rfc6749).

## Documentation
Here is the [documentation](https://shimizutaisei.github.io/oauth-for-vapor/documentation/vaporoauth) build by DocC

## How to Use
### Add Package Dependencies
```swift:Package.swift
let package = Package(
    ...,
    dependencies: [        
        ...,
        .package(url: "https://github.com/ShimizuTaisei/oauth-for-vapor.git", branch: "main")
    ],
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

### Import
```swift:ImportExample.swift
import VaporOAuth
```
