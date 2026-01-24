# Swift Security Guidelines

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] Sensitive data encrypted at rest
- [ ] Keychain used for credentials
- [ ] Certificate pinning for sensitive APIs
- [ ] Error messages don't leak sensitive data
- [ ] No sensitive data in logs

## Secret Management

```swift
// NEVER: Hardcoded secrets
let apiKey = "sk-proj-xxxxx"
```

## Configuration via Environment

```swift
// Use xcconfig or Info.plist for environment-specific values
enum Configuration {
    static var apiBaseURL: String {
        guard let url = Bundle.main.infoDictionary?["API_BASE_URL"] as? String else {
            fatalError("API_BASE_URL not configured")
        }
        return url
    }

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
```

## Input Validation

```swift
struct Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    static func sanitize(_ input: String) -> String {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
```

## Secure Networking

```swift
// Certificate Pinning
final class PinnedURLSessionDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [SecCertificate]

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate certificate chain
        // ...

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}
```

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Assess severity (CRITICAL, HIGH, MEDIUM, LOW)
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review entire codebase for similar issues
