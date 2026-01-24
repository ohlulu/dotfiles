# Swift Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, ViewModels, Services
2. **Integration Tests** - API clients, database operations
3. **UI Tests** - Critical user flows (XCUITest)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## XCTest Patterns

### makeSUT Factory (Required)

Prefer factory methods over `setUp()` with implicitly unwrapped optionals.

```swift
// ❌ BAD: setUp with implicitly unwrapped optional
final class MyTests: XCTestCase {
    var sut: MyClass!

    override func setUp() {
        sut = MyClass()
    }
}

// ✅ GOOD: makeSUT factory method
@MainActor
final class MyTests: XCTestCase {
    func test_example() {
        let sut = makeSUT()
        // ...
    }
}

private extension MyTests {
    func makeSUT(
        dependency: Dependency = .default,
        file: StaticString = #file,
        line: UInt = #line
    ) -> MyClass {
        let sut = MyClass(dependency: dependency)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
```

**Benefits:**
- Avoids implicitly unwrapped optionals
- Makes dependencies explicit and customizable per test
- Includes `file`/`line` for better error reporting
- Each test is self-contained and independent
- Automatically detects memory leaks via `trackMemoryLeaks`

### Memory Leak Tracking (Required for Reference Types)

Every `makeSUT` that creates a reference type (class, actor) **must** call `trackMemoryLeaks`.

```swift
// In Tests/Shared/SharedHelpers.swift
extension XCTestCase {
    @MainActor
    func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
```

**Why this matters:**
- Catches retain cycles immediately when introduced
- Test fails at the exact location where the leaky instance was created
- Prevents memory leaks from accumulating unnoticed

### Protocol-Based Mocking

```swift
// Define protocol
protocol UserStorage {
    func fetchUser(id: String) async throws -> User?
}

// Production implementation
final class DBUserStorage: UserStorage {
    func fetchUser(id: String) async throws -> User? {
        // Real implementation
    }
}

// Mock for testing
final class UserStorageSpy: UserStorage {
    var mockUser: User?
    var shouldThrowError = false
    var fetchUserCallCount = 0

    func fetchUser(id: String) async throws -> User? {
        fetchUserCallCount += 1
        if shouldThrowError { throw NetworkError.serverError }
        return mockUser
    }
}
```

## Test Naming Convention

```
test_[method]_[condition]_[expected]
```

Examples:
- `test_add_withPositiveNumbers_returnsSum`
- `test_fetchUser_withInvalidId_throwsError`
- `test_login_withEmptyPassword_showsValidationError`

## Test Commands

```bash
# SPM
swift test
swift test --filter MyTests
swift test --enable-code-coverage

# Xcode
xcodebuild test -scheme MyScheme -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Troubleshooting Test Failures

1. Use **swift-tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **swift-tdd-guide** - Use PROACTIVELY for new features
- **swift-build-error-resolver** - When build/test fails
