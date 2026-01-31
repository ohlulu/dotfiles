# Verification Loop Skill

A comprehensive verification system for Swift/iOS projects in Claude Code sessions.

## When to Use

Invoke this skill:
- After completing a feature or significant code change
- Before creating a PR
- When you want to ensure quality gates pass
- After refactoring

## Verification Phases

### Phase 1: Build Verification
```bash
# Swift Package Manager
swift build 2>&1 | tail -20

# Xcode project
xcodebuild -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | tail -30
```

If build fails, STOP and fix before continuing.

### Phase 2: Compiler Warnings Check
```bash
# SPM with warnings
swift build 2>&1 | grep -i "warning:" | head -20

# Xcode project
xcodebuild -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -i "warning:" | head -20
```

Report all warnings. Fix critical ones before continuing.

### Phase 3: Lint Check
```bash
# SwiftLint (if available)
swiftlint lint --quiet 2>&1 | head -30

# SwiftFormat check
swiftformat --lint . 2>&1 | head -30
```

### Phase 4: Test Suite
```bash
# SPM tests with coverage
swift test --enable-code-coverage 2>&1 | tail -50

# Xcode tests
xcodebuild test -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES 2>&1 | tail -50

# View coverage report (SPM)
xcrun llvm-cov report .build/debug/<PackageName>PackageTests.xctest/Contents/MacOS/<PackageName>PackageTests -instr-profile .build/debug/codecov/default.profdata
```

Report:
- Total tests: X
- Passed: X
- Failed: X
- Coverage: X%

Target: 80% minimum

### Phase 5: Security Scan
```bash
# Check for hardcoded secrets
grep -rn "sk-" --include="*.swift" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.swift" . 2>/dev/null | head -10
grep -rn "password" --include="*.swift" . 2>/dev/null | head -10

# Check for print statements (should use proper logging)
grep -rn "print(" --include="*.swift" Sources/ 2>/dev/null | head -10

# Check for force unwraps
grep -rn "!" --include="*.swift" Sources/ 2>/dev/null | grep -v "//" | grep -v "/*" | head -10

# Check for force try
grep -rn "try!" --include="*.swift" Sources/ 2>/dev/null | head -10
```

### Phase 6: Diff Review
```bash
# Show what changed
git diff --stat
git diff HEAD~1 --name-only
```

Review each changed file for:
- Unintended changes
- Missing error handling
- Force unwraps that should be optional binding
- Potential memory leaks (retain cycles)
- Proper access control (private, internal, public)

## Output Format

After running all phases, produce a verification report:

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Warnings:  [PASS/FAIL] (X warnings)
Lint:      [PASS/FAIL] (X issues)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## Continuous Mode

For long sessions, run verification every 15 minutes or after major changes:

```markdown
Set a mental checkpoint:
- After completing each function
- After finishing a component/view
- Before moving to next task

Run: /verify
```

## Swift-Specific Checks

### Memory Leak Detection
```bash
# Check for potential retain cycles (closures capturing self)
grep -rn "\[self\]" --include="*.swift" Sources/ 2>/dev/null | head -10
grep -rn "self\." --include="*.swift" Sources/ 2>/dev/null | grep -v "\[weak self\]" | grep -v "\[unowned self\]" | head -10
```

### Concurrency Safety
```bash
# Check for @MainActor usage in ViewModels
grep -rn "class.*ViewModel" --include="*.swift" Sources/ -A 1 2>/dev/null | head -10

# Check for async/await patterns
grep -rn "Task {" --include="*.swift" Sources/ 2>/dev/null | head -10
```

## Integration with Hooks

This skill complements PostToolUse hooks but provides deeper verification.
Hooks catch issues immediately; this skill provides comprehensive review.
