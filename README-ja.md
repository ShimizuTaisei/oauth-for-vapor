# OAuth for Vapor
## 概要
既存のVaporプロジェクトにOAuthによる認可機能を追加します。
[OAuth 2.0(RFC 6749)](https://datatracker.ietf.org/doc/html/rfc6749)のAuthorization Code Grantに従って、アクセストークンの発行などを行います。

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
