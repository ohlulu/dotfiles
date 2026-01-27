---
description: Fix Swift build errors, compiler warnings, and SwiftLint issues incrementally. Invokes the swift-build-error-resolver agent for minimal, surgical fixes.
---

# Swift Build and Fix

This command invokes the **swift-build-error-resolver** agent to incrementally fix Swift build errors with minimal changes.

## What This Command Does

1. **Run Diagnostics**: Execute `swift build`, `xcodebuild`, `swiftlint`
2. **Parse Errors**: Group by file and sort by severity
3. **Fix Incrementally**: One error at a time
4. **Verify Each Fix**: Re-run build after each change
5. **Report Summary**: Show what was fixed and what remains

## When to Use

Use `/swift-build` when:
- `swift build` fails with errors
- `xcodebuild` reports build failures
- `swiftlint` shows warnings or errors
- SPM dependencies fail to resolve
- After pulling changes that break the build

## Diagnostic Commands Run

```bash
# Primary build check (SPM)
swift build

# Primary build check (Xcode project)
xcodebuild -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 15' build

# Static analysis (if available)
swiftlint lint --strict
swiftformat --lint .

# Package issues
swift package resolve
swift package update
```

## Example Session

```text
User: /swift-build

Agent:
# Swift Build Resolution

## Initial Diagnostics

```bash
$ swift build
Sources/Service/UserService.swift:25:15: error: cannot find 'UserRepository' in scope
Sources/Handler/APIHandler.swift:42:9: error: cannot convert value of type 'String' to expected argument type 'Int'
Sources/Handler/APIHandler.swift:58:2: error: missing return in global function expected to return 'User?'
```

Errors found: 3

## Fix 1: Undefined Type

File: Sources/Service/UserService.swift:25
Error: cannot find 'UserRepository' in scope
Cause: Missing import

```swift
// Added import
import Repository

// Changed
let repo: UserRepository
// To
let repo: Repository.UserRepository
```

```bash
$ swift build
# 2 errors remaining
```

## Fix 2: Type Mismatch

File: Sources/Handler/APIHandler.swift:42
Error: cannot convert value of type 'String' to expected argument type 'Int'

```swift
// Changed
let count = params["count"]
// To
let countString = params["count"] ?? "0"
let count = Int(countString) ?? 0
```

```bash
$ swift build
# 1 error remaining
```

## Fix 3: Missing Return

File: Sources/Handler/APIHandler.swift:58
Error: missing return in global function expected to return 'User?'

```swift
func getUser(id: String) -> User? {
    guard !id.isEmpty else {
        return nil
    }
    let user = findUser(id: id)
    // Added missing return
    return user
}
```

```bash
$ swift build
# Build successful!
```

## Final Verification

```bash
$ swiftlint lint
# No violations found

$ swift test
Test Suite 'All tests' passed at 2025-01-27 10:30:00.000
     Executed 42 tests, with 0 failures (0 unexpected) in 1.234 seconds
```

## Summary

| Metric | Count |
|--------|-------|
| Build errors fixed | 3 |
| Lint warnings fixed | 0 |
| Files modified | 2 |
| Remaining issues | 0 |

Build Status: SUCCESS
```

## Common Errors Fixed

| Error | Typical Fix |
|-------|-------------|
| `cannot find 'X' in scope` | Add import or fix typo |
| `cannot convert value of type 'X' to 'Y'` | Type conversion or fix assignment |
| `missing return` | Add return statement |
| `does not conform to protocol 'X'` | Add missing protocol requirements |
| `circular reference` | Restructure dependencies |
| `value 'X' was defined but never used` | Remove or use variable |
| `no such module 'X'` | Add package dependency or fix import |
| `ambiguous use of 'X'` | Add module prefix or explicit type annotation |

## Fix Strategy

1. **Build errors first** - Code must compile
2. **Compiler warnings second** - Fix suspicious constructs
3. **Lint warnings third** - Style and best practices
4. **One fix at a time** - Verify each change
5. **Minimal changes** - Don't refactor, just fix

## Stop Conditions

The agent will stop and report if:
- Same error persists after 3 attempts
- Fix introduces more errors
- Requires architectural changes
- Missing external dependencies (suggest `swift package resolve`)

## Xcode-Specific Commands

```bash
# Build for iOS Simulator
xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build for macOS
xcodebuild -scheme MyApp -destination 'platform=macOS' build

# Clean build folder
xcodebuild clean -scheme MyApp

# List available schemes
xcodebuild -list

# Show build settings
xcodebuild -scheme MyApp -showBuildSettings
```

## SwiftLint Integration

```bash
# Run lint check
swiftlint lint

# Auto-fix violations
swiftlint lint --fix

# Lint specific file
swiftlint lint --path Sources/MyFile.swift

# Strict mode (warnings become errors)
swiftlint lint --strict
```

## Related Commands

- `/swift-test` - Run tests after build succeeds
- `/swift-review` - Review code quality
- `/verify` - Full verification loop

## Related

- Agent: `agents/swift-build-error-resolver.md`
- Skill: `skills/swift-patterns/`
