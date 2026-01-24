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

## Error Handling

ALWAYS handle errors with Swift's type system:

```swift
// Define specific errors
enum NetworkError: Error {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingFailed
}

// Use Result or throws
func fetchData() async throws -> Data {
    guard let url = URL(string: endpoint) else {
        throw NetworkError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
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
