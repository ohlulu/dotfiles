---
description: Enforce TDD workflow for Swift. Write tests first using XCTest or Swift Testing, then implement. Verify 80%+ coverage with swift test --enable-code-coverage.
---

# Swift TDD Command

This command enforces test-driven development methodology for Swift code using XCTest and Swift Testing frameworks.

## What This Command Does

1. **Define Types/Protocols**: Scaffold function signatures first
2. **Write Parameterized Tests**: Create comprehensive test cases (RED)
3. **Run Tests**: Verify tests fail for the right reason
4. **Implement Code**: Write minimal code to pass (GREEN)
5. **Refactor**: Improve while keeping tests green
6. **Check Coverage**: Ensure 80%+ coverage

## When to Use

Use `/swift-test` when:
- Implementing new Swift functions
- Adding test coverage to existing code
- Fixing bugs (write failing test first)
- Building critical business logic
- Learning TDD workflow in Swift

## TDD Cycle

```
RED     → Write failing test
GREEN   → Implement minimal code to pass
REFACTOR → Improve code, tests stay green
REPEAT  → Next test case
```

## Example Session (XCTest)

```text
User: /swift-test I need a function to validate email addresses

Agent:
# TDD Session: Email Validator

## Step 1: Define Interface

```swift
// Sources/Validator/EmailValidator.swift

/// Validates email addresses according to RFC 5322.
/// - Parameter email: The email string to validate.
/// - Returns: A validation result indicating success or the specific error.
enum EmailValidationError: Error, Equatable {
    case empty
    case invalidFormat
}

func validateEmail(_ email: String) throws {
    fatalError("Not implemented")
}
```

## Step 2: Write Tests (RED)

```swift
// Tests/ValidatorTests/EmailValidatorTests.swift
import XCTest
@testable import Validator

final class EmailValidatorTests: XCTestCase {
    
    // MARK: - Valid Emails
    
    func testValidEmail_simple() throws {
        XCTAssertNoThrow(try validateEmail("user@example.com"))
    }
    
    func testValidEmail_withSubdomain() throws {
        XCTAssertNoThrow(try validateEmail("user@mail.example.com"))
    }
    
    func testValidEmail_withPlus() throws {
        XCTAssertNoThrow(try validateEmail("user+tag@example.com"))
    }
    
    func testValidEmail_withDots() throws {
        XCTAssertNoThrow(try validateEmail("first.last@example.com"))
    }
    
    // MARK: - Invalid Emails
    
    func testInvalidEmail_empty() {
        XCTAssertThrowsError(try validateEmail("")) { error in
            XCTAssertEqual(error as? EmailValidationError, .empty)
        }
    }
    
    func testInvalidEmail_noAtSign() {
        XCTAssertThrowsError(try validateEmail("userexample.com")) { error in
            XCTAssertEqual(error as? EmailValidationError, .invalidFormat)
        }
    }
    
    func testInvalidEmail_noDomain() {
        XCTAssertThrowsError(try validateEmail("user@")) { error in
            XCTAssertEqual(error as? EmailValidationError, .invalidFormat)
        }
    }
    
    func testInvalidEmail_noLocalPart() {
        XCTAssertThrowsError(try validateEmail("@example.com")) { error in
            XCTAssertEqual(error as? EmailValidationError, .invalidFormat)
        }
    }
}
```

## Step 3: Run Tests - Verify FAIL

```bash
$ swift test --filter EmailValidatorTests

Test Suite 'EmailValidatorTests' started
Test Case 'EmailValidatorTests.testValidEmail_simple' failed
    Fatal error: Not implemented

FAILED: 8 tests, 8 failures
```

Tests fail as expected (fatalError).

## Step 4: Implement Minimal Code (GREEN)

```swift
// Sources/Validator/EmailValidator.swift
import Foundation

enum EmailValidationError: Error, Equatable {
    case empty
    case invalidFormat
}

private let emailRegex = try! NSRegularExpression(
    pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
)

func validateEmail(_ email: String) throws {
    guard !email.isEmpty else {
        throw EmailValidationError.empty
    }
    
    let range = NSRange(email.startIndex..., in: email)
    guard emailRegex.firstMatch(in: email, range: range) != nil else {
        throw EmailValidationError.invalidFormat
    }
}
```

## Step 5: Run Tests - Verify PASS

```bash
$ swift test --filter EmailValidatorTests

Test Suite 'EmailValidatorTests' passed
     Executed 8 tests, with 0 failures in 0.015 seconds
```

All tests passing!

## Step 6: Check Coverage

```bash
$ swift test --enable-code-coverage
$ xcrun llvm-cov report .build/debug/ValidatorPackageTests.xctest/Contents/MacOS/ValidatorPackageTests \
    --instr-profile .build/debug/codecov/default.profdata

Filename                    Regions    Miss   Cover
EmailValidator.swift              5       0  100.00%
```

Coverage: 100%

## TDD Complete!
```

## Example Session (Swift Testing - iOS 18+/macOS 15+)

```swift
// Tests/ValidatorTests/EmailValidatorTests.swift
import Testing
@testable import Validator

@Suite("Email Validation")
struct EmailValidatorTests {
    
    @Test("Valid email formats", arguments: [
        "user@example.com",
        "user@mail.example.com",
        "user+tag@example.com",
        "first.last@example.com"
    ])
    func validEmails(email: String) throws {
        #expect(throws: Never.self) {
            try validateEmail(email)
        }
    }
    
    @Test("Empty email throws empty error")
    func emptyEmail() {
        #expect(throws: EmailValidationError.empty) {
            try validateEmail("")
        }
    }
    
    @Test("Invalid email formats", arguments: [
        "userexample.com",
        "user@",
        "@example.com",
        "user@@example.com"
    ])
    func invalidEmails(email: String) {
        #expect(throws: EmailValidationError.invalidFormat) {
            try validateEmail(email)
        }
    }
}
```

## Test Patterns

### XCTest Parameterized (Manual)

```swift
final class CalculatorTests: XCTestCase {
    func testAddition() {
        let testCases: [(a: Int, b: Int, expected: Int)] = [
            (1, 1, 2),
            (0, 0, 0),
            (-1, 1, 0),
            (100, 200, 300)
        ]
        
        for tc in testCases {
            XCTAssertEqual(
                add(tc.a, tc.b), 
                tc.expected, 
                "add(\(tc.a), \(tc.b)) should equal \(tc.expected)"
            )
        }
    }
}
```

### Swift Testing Parameterized

```swift
@Test("Addition", arguments: [
    (1, 1, 2),
    (0, 0, 0),
    (-1, 1, 0),
    (100, 200, 300)
])
func addition(a: Int, b: Int, expected: Int) {
    #expect(add(a, b) == expected)
}
```

### Async Tests (XCTest)

```swift
func testAsyncFetch() async throws {
    let service = UserService()
    let user = try await service.fetchUser(id: "123")
    XCTAssertEqual(user.name, "John")
}
```

### Async Tests (Swift Testing)

```swift
@Test("Async user fetch")
func asyncFetch() async throws {
    let service = UserService()
    let user = try await service.fetchUser(id: "123")
    #expect(user.name == "John")
}
```

### Test Setup/Teardown

```swift
// XCTest
final class DatabaseTests: XCTestCase {
    var database: Database!
    
    override func setUp() async throws {
        database = try await Database.inMemory()
    }
    
    override func tearDown() async throws {
        try await database.close()
    }
}

// Swift Testing
@Suite struct DatabaseTests {
    let database: Database
    
    init() async throws {
        database = try await Database.inMemory()
    }
    
    deinit {
        // Cleanup if needed
    }
}
```

## Coverage Commands

```bash
# Run tests with coverage (SPM)
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov report \
    .build/debug/YourPackageTests.xctest/Contents/MacOS/YourPackageTests \
    --instr-profile .build/debug/codecov/default.profdata

# Export to HTML
xcrun llvm-cov show \
    .build/debug/YourPackageTests.xctest/Contents/MacOS/YourPackageTests \
    --instr-profile .build/debug/codecov/default.profdata \
    --format=html > coverage.html

# Xcode project coverage
xcodebuild test \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -enableCodeCoverage YES

# View Xcode coverage
xcrun xccov view --report DerivedData/.../Logs/Test/*.xcresult
```

## Coverage Targets

| Code Type | Target |
|-----------|--------|
| Critical business logic | 100% |
| Public APIs | 90%+ |
| General code | 80%+ |
| Generated code | Exclude |
| UI code | 60%+ (consider UI tests) |

## TDD Best Practices

**DO:**
- Write test FIRST, before any implementation
- Run tests after each change
- Use parameterized tests for comprehensive coverage
- Test behavior, not implementation details
- Include edge cases (empty, nil, boundary values)
- Use `async/await` for async code testing
- Prefer Swift Testing for new code (iOS 18+/macOS 15+)

**DON'T:**
- Write implementation before tests
- Skip the RED phase
- Test private functions directly (test through public API)
- Use `Thread.sleep` or `usleep` in tests
- Ignore flaky tests
- Over-mock dependencies

## XCTest vs Swift Testing

| Feature | XCTest | Swift Testing |
|---------|--------|---------------|
| Availability | All versions | iOS 18+, macOS 15+ |
| Parameterized | Manual loops | `@Test(arguments:)` |
| Assertions | `XCTAssert*` | `#expect`, `#require` |
| Suites | `XCTestCase` class | `@Suite` struct |
| Async | `async throws` | `async throws` |
| Parallelism | Per-class | Per-test |

## Related Commands

- `/swift-build` - Fix build errors
- `/swift-review` - Review code after implementation
- `/verify` - Run full verification loop

## Related

- Skill: `skills/swift-testing/`
- Skill: `skills/swift-tdd-workflow/`
