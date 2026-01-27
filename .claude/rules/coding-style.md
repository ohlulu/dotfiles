# Swift Coding Style

## Immutability (CRITICAL)

ALWAYS prefer immutable types:

```swift
// WRONG: Mutable class
class User {
    var name: String  // MUTATION!
}

// CORRECT: Immutable struct
struct User {
    let name: String
}

// CORRECT: Copy-on-write for updates
func updateUser(_ user: User, name: String) -> User {
    User(name: name)
}
```

## Value Types vs Reference Types

- **Prefer structs** over classes
- Use **classes** only when:
  - Identity matters (not just value)
  - Inheritance is needed
  - Objective-C interop required

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- One type per file (generally)
- Organize by feature/domain

## Nested Types

When types are **simple and closely related**, prefer nested types over separate files:

```swift
// WRONG: Separate file for NetworkError
// NetworkError.swift
enum NetworkError: Error {
    case invalidURL
    case serverError(statusCode: Int)
}

// CORRECT: Nested type within parent
// Network.swift
enum Network {
    enum Error: Swift.Error {
        case invalidURL
        case serverError(statusCode: Int)
        case decodingFailed
    }

    struct Request {
        let url: URL
        let method: HTTPMethod
    }

    enum HTTPMethod {
        case get, post, put, delete
    }
}

// Usage: Network.Error, Network.Request, Network.HTTPMethod
```

**When to use nested types:**
- Error types specific to a module (`Network.Error`, `Parser.Error`)
- Configuration types (`Service.Configuration`)
- State enums (`ViewModel.State`, `View.Action`)
- Small helper types used only by parent

**When to use separate files:**
- Type is used across multiple modules
- Type has complex logic (>50 lines)
- Type needs its own tests

## Error Handling

ALWAYS handle errors with Swift's type system:

```swift
// Define errors as nested type (see Nested Types section)
enum Network {
    enum Error: Swift.Error {
        case invalidURL
        case serverError(statusCode: Int)
        case decodingFailed
    }
}

// Use Result or throws
func fetchData() async throws -> Data {
    guard let url = URL(string: endpoint) else {
        throw Network.Error.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw Network.Error.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
    }

    return data
}
```

## Optionals

NEVER force unwrap in production code:

```swift
// WRONG
let name = user.name!

// CORRECT: Guard
guard let name = user.name else { return }

// CORRECT: Optional binding
if let name = user.name {
    print(name)
}

// CORRECT: Nil coalescing
let name = user.name ?? "Unknown"
```

## Naming Conventions

- **Types**: UpperCamelCase (`UserProfile`, `NetworkService`)
- **Variables/Functions**: lowerCamelCase (`userName`, `fetchData()`)
- **Constants**: lowerCamelCase (`maxRetryCount`)
- **Protocols**: UpperCamelCase, often `-able`, `-ible`, `-ing` (`Codable`, `Loading`)

## Documentation Comments

Use documentation comments (`///`) instead of regular comments (`//`) for explaining code:

```swift
// WRONG: Regular comment
var pricingType: String // "simple" | "variant"
var price: String // Decimal as String

// CORRECT: Documentation comment
/// Pricing type: "simple" | "variant"
var pricingType: String
/// Decimal stored as String for precision.
var price: String
```

**Guidelines:**
- Use `///` for type, property, and method documentation
- Keep documentation concise (one line when possible)
- Document non-obvious behavior or constraints
- No need to document self-explanatory properties

## Prevent unnecessary `self`

NEVER use `self` in methods that don't modify instance state:

```swift
// WRONG
class User {
  func doSomething() {
    self.doSomething2()
  }

  func doSomething2() {
    // ... some logic ...
  }
}

// CORRECT
class User {
  func doSomething() {
    self.doSomething2()
  }

  func doSomething2() {
    // ... some logic ...
  }
}

```

## Code Quality Checklist

Before marking work complete:
- [ ] Prefer structs over classes
- [ ] No force unwraps (`!`)
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling (no silent failures)
- [ ] No print statements in production
- [ ] No hardcoded values (use constants)
- [ ] Access control is explicit (private, internal, public)
- [ ] Related simple types use nested structure (`Parent.Error`, `Parent.State`)
