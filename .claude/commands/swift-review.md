---
description: Comprehensive Swift code review for idiomatic patterns, memory safety, concurrency, and security. Invokes the code-reviewer agent with Swift focus.
---

# Swift Code Review

This command invokes the **code-reviewer** agent for comprehensive Swift-specific code review.

## What This Command Does

1. **Identify Swift Changes**: Find modified `.swift` files via `git diff`
2. **Run Static Analysis**: Execute `swiftlint`, `swiftformat --lint`
3. **Security Scan**: Check for hardcoded secrets, insecure storage, injection risks
4. **Memory Review**: Analyze retain cycles, weak/unowned usage, memory leaks
5. **Concurrency Review**: Check Swift Concurrency patterns, actor isolation, Sendable
6. **Idiomatic Swift Check**: Verify code follows Swift conventions and best practices
7. **Generate Report**: Categorize issues by severity

## When to Use

Use `/swift-review` when:
- After writing or modifying Swift code
- Before committing Swift changes
- Reviewing pull requests with Swift code
- Onboarding to a new Swift codebase
- Learning idiomatic Swift patterns

## Review Categories

### CRITICAL (Must Fix)

- **Memory Leaks**: Strong reference cycles in closures
- **Security**: Hardcoded API keys, credentials in code
- **Data Races**: Unprotected shared mutable state
- **Force Unwrap**: `!` on optionals in production code
- **Keychain Misuse**: Storing sensitive data in UserDefaults
- **Insecure Network**: HTTP without App Transport Security exception justification

### HIGH (Should Fix)

- **Retain Cycles**: Missing `[weak self]` or `[unowned self]` in closures
- **@MainActor Missing**: UI updates from background thread
- **Sendable Violations**: Non-Sendable types crossing actor boundaries
- **Error Handling**: Silently catching errors without logging
- **Implicitly Unwrapped Optionals**: `!` in properties without justification
- **@StateObject vs @ObservedObject**: Incorrect ownership in SwiftUI

### MEDIUM (Consider)

- **Non-idiomatic Code**: Not using Swift conventions
- **Missing Documentation**: No doc comments on public APIs
- **Large Functions**: Functions > 50 lines
- **Deep Nesting**: > 4 levels of indentation
- **Magic Numbers**: Undocumented literal values
- **Print Statements**: `print()` left in production code

## Automated Checks Run

```bash
# Static analysis
swiftlint lint --strict

# Code formatting check
swiftformat --lint .

# Build with warnings as errors
swift build -Xswiftc -warnings-as-errors

# Xcode analyze (if project exists)
xcodebuild analyze -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Example Usage

```text
User: /swift-review

Agent:
# Swift Code Review Report

## Files Reviewed
- Sources/Services/UserService.swift (modified)
- Sources/ViewModels/ProfileViewModel.swift (modified)

## Static Analysis Results
swiftlint: 2 warnings
swiftformat: No issues

## Issues Found

[CRITICAL] Retain Cycle - Memory Leak
File: Sources/ViewModels/ProfileViewModel.swift:45
Issue: Strong reference to self in escaping closure

```swift
// Problem: self captured strongly
networkService.fetchUser { user in
    self.user = user  // Retain cycle!
    self.isLoading = false
}
```

Fix: Capture self weakly

```swift
networkService.fetchUser { [weak self] user in
    guard let self else { return }
    self.user = user
    self.isLoading = false
}
```

[HIGH] Missing @MainActor
File: Sources/ViewModels/ProfileViewModel.swift:52
Issue: UI property updated potentially from background thread

```swift
// Problem: @Published property may be set from background
@Published var user: User?

func fetchUser() {
    Task {
        let user = try await api.getUser()
        self.user = user  // May not be on main thread!
    }
}
```

Fix: Use @MainActor or MainActor.run

```swift
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    func fetchUser() {
        Task {
            let user = try await api.getUser()
            self.user = user  // Now guaranteed on main thread
        }
    }
}
```

[MEDIUM] Force Unwrap
File: Sources/Services/UserService.swift:28
Issue: Force unwrap on optional value

```swift
let url = URL(string: endpoint)!  // Crash if invalid
```

Fix: Use guard or if-let

```swift
guard let url = URL(string: endpoint) else {
    throw NetworkError.invalidURL(endpoint)
}
```

## Summary
- CRITICAL: 1
- HIGH: 1
- MEDIUM: 1

Recommendation: Block merge until CRITICAL issue is fixed
```

## Memory Safety Checklist

### Closures

```swift
// BAD: Strong capture
someAsyncOperation { 
    self.property = value  // Retain cycle if self holds closure
}

// GOOD: Weak capture
someAsyncOperation { [weak self] in
    self?.property = value
}

// GOOD: Unowned (when self outlives closure)
someAsyncOperation { [unowned self] in
    self.property = value
}
```

### SwiftUI Property Wrappers

| Wrapper | Ownership | Use When |
|---------|-----------|----------|
| `@StateObject` | View owns | Creating observable in view |
| `@ObservedObject` | External owns | Passed from parent |
| `@EnvironmentObject` | Environment owns | Shared across hierarchy |
| `@State` | View owns | Simple value types |
| `@Binding` | Parent owns | Two-way connection |

### Common Retain Cycles

```swift
// Timer - must invalidate
class ViewController {
    var timer: Timer?
    
    func startTimer() {
        // BAD: self strongly captured
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.update()
        }
        
        // GOOD: weak capture
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.update()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

// NotificationCenter - must remove observer
class Observer {
    var observation: NSObjectProtocol?
    
    init() {
        observation = NotificationCenter.default.addObserver(
            forName: .someNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleNotification()
        }
    }
    
    deinit {
        if let observation {
            NotificationCenter.default.removeObserver(observation)
        }
    }
}
```

## Swift Concurrency Checklist

### Actor Isolation

```swift
// GOOD: Properly isolated actor
actor UserCache {
    private var cache: [String: User] = [:]
    
    func get(_ id: String) -> User? {
        cache[id]
    }
    
    func set(_ user: User, for id: String) {
        cache[id] = user
    }
}

// Usage
let user = await userCache.get("123")
```

### Sendable Compliance

```swift
// BAD: Non-Sendable class crossing boundaries
class UserData {  // Not Sendable!
    var name: String
}

// GOOD: Make it Sendable
final class UserData: Sendable {
    let name: String  // Must be immutable or properly synchronized
}

// Or use struct
struct UserData: Sendable {
    var name: String
}
```

### MainActor for UI

```swift
// GOOD: ViewModel on MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func load() {
        Task {
            let items = try await api.fetchItems()
            self.items = items  // Safe - on MainActor
        }
    }
}
```

## Security Checklist

### Sensitive Data Storage

```swift
// BAD: Storing secrets in UserDefaults
UserDefaults.standard.set(apiKey, forKey: "apiKey")

// GOOD: Use Keychain
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "apiKey",
    kSecValueData as String: apiKey.data(using: .utf8)!
]
SecItemAdd(query as CFDictionary, nil)
```

### Hardcoded Secrets

```swift
// BAD: Hardcoded credentials
let apiKey = "sk-1234567890abcdef"

// GOOD: Environment or configuration
let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""

// GOOD: Xcconfig / Info.plist
let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? ""
```

## Approval Criteria

| Status | Condition |
|--------|-----------|
| Approve | No CRITICAL or HIGH issues |
| Warning | Only MEDIUM issues (merge with caution) |
| Block | CRITICAL or HIGH issues found |

## Integration with Other Commands

- Use `/swift-test` first to ensure tests pass
- Use `/swift-build` if build errors occur
- Use `/swift-review` before committing
- Use `/code-review` for non-Swift specific concerns

## Related

- Agent: `agents/code-reviewer.md`
- Skills: `skills/swift-patterns/`, `skills/swift-concurrency/`
