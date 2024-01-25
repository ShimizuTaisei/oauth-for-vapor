# Adding Authorization Code Grant to Your Project

Adding Authorization Code Grant to your project.

## Overview

You can add authorization code grant with following steps.

### Define models
You have to define models to store OAuth data(such as access-token).
To support authorization code grant, create models which conform following protocols.
* <doc:AuthorizationCode>
* <doc:AuthorizationCodeScope>
* <doc:AccessToken>
* <doc:AccessTokenScope>
* <doc:RefreshToken>
* <doc:RefreshTokenScope>

And you can use macros to implement　properties required for protocol conformation.<br>
Following macros are available.
* <doc:AuthorizationCodeModel()>
* <doc:AuthorizationCodeScopeModel()>
* <doc:AccessTokenModel()>
* <doc:AccessTokenScopeModel()>
* <doc:RefreshTokenModel()>
* <doc:RefreshTokenScopeModel()>

Then, implement `var schema` and `typealias`.
```swift
@AccessTokenModel
public final class AccessTokens: AccessToken {
    public static var schema: String = "oauth_access_tokens"
    public typealias User = Users
    public typealias AccessTokenScopeType = AccessTokenScopes
}
```
