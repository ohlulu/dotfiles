# Swift Common Patterns

## API Response Format

```swift
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: String?
    let meta: PageMeta?
}

struct PageMeta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
}
```

## Repository Pattern

```swift
protocol Repository {
    associatedtype Entity
    associatedtype ID

    func findAll() async throws -> [Entity]
    func find(by id: ID) async throws -> Entity?
    func create(_ entity: Entity) async throws -> Entity
    func update(_ entity: Entity) async throws -> Entity
    func delete(by id: ID) async throws
}

final class UserRepository: Repository {
    typealias Entity = User
    typealias ID = String

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func findAll() async throws -> [User] {
        try await apiClient.request(.users)
    }

    // ... other methods
}
```

## Protocol-Based Dependency Injection

```swift
// Define protocol
protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User?
}

// Production implementation
final class UserService: UserServiceProtocol {
    func fetchUser(id: String) async throws -> User? {
        // Real implementation
    }
}

// Mock for testing
final class MockUserService: UserServiceProtocol {
    var mockUser: User?
    var shouldThrowError = false

    func fetchUser(id: String) async throws -> User? {
        if shouldThrowError { throw TestError.mock }
        return mockUser
    }
}

// Usage with DI
final class UserViewModel: ObservableObject {
    private let service: UserServiceProtocol

    init(service: UserServiceProtocol = UserService()) {
        self.service = service
    }
}
```

## Result Type Pattern

```swift
enum NetworkResult<T> {
    case success(T)
    case failure(Error)
}

func fetchData<T: Decodable>(from url: URL) async -> NetworkResult<T> {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return .success(decoded)
    } catch {
        return .failure(error)
    }
}
```

## Combine Publisher Pattern

```swift
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [Item] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                Task { await self?.search(query) }
            }
            .store(in: &cancellables)
    }
}
```

## Actor for Thread Safety

```swift
actor DataStore {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        cache[key]
    }

    func set(_ key: String, value: Data) {
        cache[key] = value
    }

    func clear() {
        cache.removeAll()
    }
}
```

## Skeleton Projects

When implementing new functionality:
1. Search for battle-tested skeleton projects
2. Evaluate: security, extensibility, relevance
3. Clone best match as foundation
4. Iterate within proven structure
