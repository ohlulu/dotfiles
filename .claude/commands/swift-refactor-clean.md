---
description: Safely identify and remove dead Swift code with test verification. Uses Periphery for unused code detection and SwiftLint for analysis.
---

# Swift Refactor Clean

Safely identify and remove dead code with test verification.

## What This Command Does

1. **Run Dead Code Analysis**:
   - Periphery: Find unused declarations (classes, functions, properties)
   - SwiftLint: Find unused imports and variables
   - Manual scan: Find orphaned files

2. **Generate Report**: Create `.reports/dead-code-analysis.md`

3. **Categorize Findings**:
   - SAFE: Test files, unused private utilities
   - CAUTION: Public APIs, protocols, view models
   - DANGER: App delegates, entry points, @main

4. **Propose Safe Deletions Only**

5. **Before Each Deletion**:
   - Run full test suite
   - Verify tests pass
   - Apply change
   - Re-run tests
   - Rollback if tests fail

6. **Show Summary** of cleaned items

## When to Use

Use `/swift-refactor-clean` when:
- Codebase has accumulated dead code
- After major refactoring
- Before a new release
- Reducing build times
- Improving code maintainability

## Dead Code Detection Tools

### Periphery (Primary Tool)

```bash
# Install
brew install periphery

# Scan SPM project
periphery scan

# Scan Xcode project
periphery scan --project MyApp.xcodeproj --schemes MyApp --targets MyApp

# Output formats
periphery scan --format json > dead-code.json
periphery scan --format csv > dead-code.csv
periphery scan --format checkstyle > dead-code.xml

# Strict mode (more aggressive)
periphery scan --strict

# Exclude test targets
periphery scan --skip-build --index-store-path .build/debug/index/store
```

### SwiftLint Rules

```yaml
# .swiftlint.yml
opt_in_rules:
  - unused_import
  - unused_declaration
  - unused_closure_parameter

analyzer_rules:
  - unused_import
  - unused_declaration
```

```bash
# Run analyzer rules
swiftlint analyze --compiler-log-path build.log
```

## Example Session

```text
User: /swift-refactor-clean

Agent:
# Dead Code Analysis Report

## Scan Results

```bash
$ periphery scan --project MyApp.xcodeproj --schemes MyApp

Scanning...
Found 847 declarations
Analyzing...
```

## Unused Code Found

### SAFE TO REMOVE (12 items)

| File | Declaration | Type | Confidence |
|------|-------------|------|------------|
| Utils/StringHelpers.swift | `formatLegacyDate()` | Function | 100% |
| Utils/StringHelpers.swift | `legacyDateFormat` | Property | 100% |
| Models/OldUser.swift | `OldUser` | Class | 100% |
| Models/OldUser.swift | `migrate()` | Method | 100% |
| Extensions/Array+Old.swift | (entire file) | Extension | 100% |

### CAUTION - VERIFY BEFORE REMOVING (5 items)

| File | Declaration | Type | Risk |
|------|-------------|------|------|
| Services/AnalyticsService.swift | `trackLegacyEvent()` | Method | May be called via reflection |
| Protocols/Cacheable.swift | `Cacheable` | Protocol | Check for dynamic conformance |
| ViewModels/SettingsViewModel.swift | `debugMode` | Property | May be used in DEBUG builds |

### DANGER - DO NOT AUTO-REMOVE (2 items)

| File | Declaration | Reason |
|------|-------------|--------|
| AppDelegate.swift | `application(_:continue:)` | System callback |
| SceneDelegate.swift | `stateRestorationActivity` | System callback |

## Safe Removal Process

### Step 1: Remove `formatLegacyDate()`

```bash
$ swift test
Test Suite 'All tests' passed (42 tests)
```

Removing function from Utils/StringHelpers.swift...

```bash
$ swift test
Test Suite 'All tests' passed (42 tests)
```

Removal successful.

### Step 2: Remove `OldUser` class

```bash
$ swift test
Test Suite 'All tests' passed (42 tests)
```

Removing Models/OldUser.swift...

```bash
$ swift test
Test Suite 'All tests' passed (42 tests)
```

Removal successful.

### Step 3: Remove Array+Old.swift

```bash
$ swift test
Test Suite 'All tests' passed (42 tests)
```

Removing Extensions/Array+Old.swift...

```bash
$ swift test
Test Suite 'All tests' passed (42 tests)
```

Removal successful.

## Summary

| Metric | Count |
|--------|-------|
| Declarations scanned | 847 |
| Unused found | 19 |
| Safely removed | 12 |
| Marked for review | 5 |
| Skipped (dangerous) | 2 |
| Lines removed | ~450 |
| Test failures | 0 |

Build time improvement: ~3% (estimated)
```

## Periphery Configuration

Create `.periphery.yml` for consistent scans:

```yaml
# .periphery.yml
project: MyApp.xcodeproj
schemes:
  - MyApp
targets:
  - MyApp
  - MyAppKit

# Exclude from analysis
exclude:
  - "*/Generated/*"
  - "*/Mocks/*"
  - "*Tests*"

# Retain patterns (don't mark as unused)
retain_public: false
retain_objc_accessible: true
retain_objc_annotated: true

# Index store path for faster scans
index_store_path: .build/debug/index/store
```

## Common False Positives

### Codable Properties

```swift
// Used by decoder but not directly referenced
struct User: Codable {
    let legacyId: String  // May be flagged
}
```

**Solution**: Add to retain list or use `// periphery:ignore`

### Protocol Witnesses

```swift
// Required by protocol but flagged as unused
extension MyClass: SomeProtocol {
    func requiredMethod() { }  // May be flagged
}
```

**Solution**: Periphery usually handles this, but verify

### @objc Methods

```swift
// Called via Objective-C runtime
@objc func handleNotification(_ notification: Notification) { }
```

**Solution**: Use `--retain-objc-annotated`

## Inline Ignore Comments

```swift
// Ignore specific declaration
// periphery:ignore
func legacyFunction() { }

// Ignore with reason
// periphery:ignore:all - Used by external SDK
class ExternalIntegration { }

// Ignore specific unused parameter
func process(
    data: Data,
    // periphery:ignore:parameters
    options: Options
) { }
```

## Categorization Rules

### SAFE (Auto-remove candidates)

- Private functions with no references
- Private properties with no references
- Internal utilities in isolated modules
- Test helpers outside test targets
- Deprecated code marked for removal

### CAUTION (Manual review required)

- Public APIs (may have external consumers)
- Protocol requirements
- Methods with `@objc` without IBAction/IBOutlet
- Closures and callbacks
- Generic type parameters

### DANGER (Never auto-remove)

- `@main` entry points
- `AppDelegate` / `SceneDelegate` methods
- System callbacks (`application(_:didFinishLaunching...)`)
- `@IBOutlet` / `@IBAction`
- `Codable` conformance properties
- Methods called via reflection or selectors

## Verification Commands

```bash
# Full test suite
swift test

# Build all targets
swift build --target MyApp --target MyAppKit

# Xcode build
xcodebuild build -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive build (catches more issues)
xcodebuild archive -scheme MyApp -archivePath build/MyApp.xcarchive
```

## Related Commands

- `/swift-build` - Fix any build errors after cleanup
- `/swift-test` - Ensure tests still pass
- `/swift-review` - Review remaining code quality

## Related

- Tool: [Periphery](https://github.com/peripheryapp/periphery)
- Skill: `skills/swift-refactoring/`
