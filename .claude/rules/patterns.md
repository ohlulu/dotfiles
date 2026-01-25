# Swift Patterns

## Quick Reference

| Pattern | One-Line Check |
|---------|----------------|
| Protocol First | Did you define protocols before implementations? |
| WeakProxy | Retain cycle between Presenter and View? |
| MainActor | Are UI updates marked with @MainActor? |
| async let | Are independent async operations running in parallel? |
| Cache Strategy | Does cached data have expiration policy? |
| Idempotency | Can this operation be safely retried? |
| Lazy Init | Are heavy objects created only when needed? |

---

## Architecture Patterns

### Protocol First + Dependency Injection

Before writing any implementation, define the protocol. Protocols are contracts, implementations are details.

```swift
// 1. Define protocol first (contract)
protocol DataLoader {
    func load() async throws -> [Item]
}

// 2. Production implementation
final class RemoteDataLoader: DataLoader {
    func load() async throws -> [Item] {
        // Real network request
    }
}

// 3. Test implementation
final class StubDataLoader: DataLoader {
    var result: Result<[Item], Error> = .success([])

    func load() async throws -> [Item] {
        try result.get()
    }
}
```

### Protocol Composition

```swift
// One object conforming to multiple protocols
private var store: DataStore & ImageCache & Sendable

// Different implementations can have different capability combinations
extension CoreDataStore: DataStore, ImageCache { }
extension InMemoryStore: DataStore { }  // Doesn't support ImageCache
```

### Composition with Adapter Pattern

Adapters connect async loading with UI updates without inheritance.

```swift
@MainActor
final class LoadingAdapter<Resource> {
    private let loader: () async throws -> Resource
    private var task: Task<Void, Never>?

    var onStart: (() -> Void)?
    var onSuccess: ((Resource) -> Void)?
    var onError: ((Error) -> Void)?

    init(loader: @escaping () async throws -> Resource) {
        self.loader = loader
    }

    func load() {
        onStart?()
        task = Task { [weak self] in
            do {
                let resource = try await self?.loader()
                if let resource { self?.onSuccess?(resource) }
            } catch {
                self?.onError?(error)
            }
        }
    }

    func cancel() {
        task?.cancel()
    }
}
```

### Composite Cell Controller

Combine multiple TableView protocols together.

```swift
struct CellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetching: UITableViewDataSourcePrefetching?
}

// Usage: same TableView can have different cell types
let controllers: [CellController] = [
    productCellController,
    adBannerCellController,
    loadMoreCellController
]
```

---

## Concurrency Patterns

### MainActor + Sendable

UI updates must happen on the main thread. Use `@MainActor` for UI-related code, use `Sendable` to ensure data can safely cross thread boundaries.

```swift
// Domain model: safe to pass across threads
struct Product: Sendable {
    let id: UUID
    let name: String
    let price: Decimal
}

// UI-related: restricted to main thread
@MainActor
protocol ProductView {
    func display(_ products: [Product])
}

@MainActor
final class ProductPresenter {
    private let view: ProductView

    func present(_ products: [Product]) {
        view.display(products)  // Guaranteed on main thread
    }
}
```

### Parallel Loading (async let)

When multiple async operations are independent, execute them simultaneously.

```swift
// BAD: Sequential execution (Total time = A + B + C)
let a = try await loadA()  // 1 second
let b = try await loadB()  // 1 second
let c = try await loadC()  // 1 second
// Total: 3 seconds

// GOOD: Parallel execution (Total time = max(A, B, C))
async let a = loadA()
async let b = loadB()
async let c = loadC()

let results = try await (a, b, c)  // 1 second
```

**Use cases:**
- Load local cache + fetch remote data simultaneously
- Product detail: load info + reviews + recommendations together
- Home page: load banner + categories + recommendations together

### Background Scheduler

```swift
protocol BackgroundScheduler {
    @MainActor
    func schedule<T: Sendable>(_ work: @escaping @Sendable () throws -> T) async rethrows -> T
}

extension CoreDataStore: BackgroundScheduler {
    @MainActor
    func schedule<T: Sendable>(_ work: @escaping @Sendable () throws -> T) async rethrows -> T {
        if Thread.isMainThread {
            return try work()
        } else {
            return try await context.perform(work)
        }
    }
}
```

---

## Memory Safety

### WeakProxy

When A holds B and B holds A, use a weak reference proxy to break the cycle.

```
Presenter ──strong──→ WeakProxy ──weak──→ View
    ↑                                      │
    └────────────strong────────────────────┘

Result: When View is deallocated, WeakProxy.object becomes nil, cycle broken
```

```swift
final class WeakProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

// Conditional conformance: only when T conforms
extension WeakProxy: LoadingView where T: LoadingView {
    func showLoading() { object?.showLoading() }
    func hideLoading() { object?.hideLoading() }
}

extension WeakProxy: ErrorView where T: ErrorView {
    func showError(message: String) { object?.showError(message: message) }
    func hideError() { object?.hideError() }
}

// Usage
let presenter = ResourcePresenter(
    view: adapter,
    loadingView: WeakProxy(viewController),
    errorView: WeakProxy(viewController)
)
```

---

## Generic Patterns

### ResourcePresenter

If you find yourself copy-pasting code and only changing type names, use generics.

```swift
@MainActor
protocol ResourceView {
    associatedtype ViewModel
    func display(_ viewModel: ViewModel)
}

@MainActor
final class ResourcePresenter<Resource, View: ResourceView> {
    typealias Mapper = (Resource) throws -> View.ViewModel

    private let view: View
    private let loadingView: LoadingView
    private let errorView: ErrorView
    private let mapper: Mapper

    init(view: View, loadingView: LoadingView, errorView: ErrorView, mapper: @escaping Mapper) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    func didStartLoading() {
        errorView.hideError()
        loadingView.showLoading()
    }

    func didFinishLoading(with resource: Resource) {
        do {
            view.display(try mapper(resource))
        } catch {
            didFinishLoading(with: error)
        }
        loadingView.hideLoading()
    }

    func didFinishLoading(with error: Error) {
        errorView.showError(message: "Loading failed")
        loadingView.hideLoading()
    }
}

// Usage:
// ResourcePresenter<[Product], ProductListView>
// ResourcePresenter<Order, OrderDetailView>
// ResourcePresenter<User, ProfileView>
```

### Conditional Extension (where)

Give generic types additional capabilities under specific conditions.

```swift
final class WeakProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) { self.object = object }
}

// Only provide capability when T is a specific type
extension WeakProxy: ResourceView where T: ResourceView, T.ViewModel == UIImage {
    func display(_ viewModel: UIImage) { object?.display(viewModel) }
}
```

**Use cases:**
- Let arrays sort only when elements are Comparable
- Let containers be Sendable only when contents are Sendable
- Let proxies provide capabilities only when wrapped objects have them

---

## Network & Resilience

### API Response Format

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

### Cache Strategy

```swift
struct CachedData<T> {
    let data: T
    let timestamp: Date
    let maxAge: TimeInterval

    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > maxAge
    }
}

enum CacheStrategy {
    /// Always use cache if available, refresh in background
    case staleWhileRevalidate
    /// Use cache only if not expired
    case cacheFirst(maxAge: TimeInterval)
    /// Always fetch fresh, cache for offline
    case networkFirst
    /// Never cache
    case noCache
}

func load(strategy: CacheStrategy) async throws -> [Item] {
    switch strategy {
    case .staleWhileRevalidate:
        if let cached = cache.get() {
            Task { try? await refreshCache() }  // Background refresh
            return cached
        }
        return try await fetchAndCache()

    case .cacheFirst(let maxAge):
        if let cached = cache.get(), cache.age < maxAge {
            return cached
        }
        return try await fetchAndCache()

    case .networkFirst:
        do {
            return try await fetchAndCache()
        } catch {
            return cache.get() ?? []
        }

    case .noCache:
        return try await fetch()
    }
}
```

### Retry with Exponential Backoff

```swift
struct RetryPolicy {
    let maxAttempts: Int
    let initialDelay: TimeInterval
    let maxDelay: TimeInterval
    let shouldRetry: (Error) -> Bool

    static let `default` = RetryPolicy(
        maxAttempts: 3,
        initialDelay: 1.0,
        maxDelay: 30.0,
        shouldRetry: { error in
            guard let urlError = error as? URLError else { return false }
            return [.timedOut, .networkConnectionLost, .notConnectedToInternet]
                .contains(urlError.code)
        }
    )
}

func fetchWithRetry<T>(
    policy: RetryPolicy = .default,
    action: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<policy.maxAttempts {
        do {
            return try await action()
        } catch {
            lastError = error

            guard policy.shouldRetry(error),
                  attempt < policy.maxAttempts - 1 else { break }

            // Exponential backoff with jitter
            let baseDelay = policy.initialDelay * pow(2.0, Double(attempt))
            let jitter = Double.random(in: 0...0.3) * baseDelay
            let delay = min(baseDelay + jitter, policy.maxDelay)

            try await Task.sleep(for: .seconds(delay))
        }
    }

    throw lastError!
}
```

### Graceful Degradation (Fallback)

```swift
func loadWithFallback() async throws -> [Item] {
    do {
        let items = try await loadFromRemote()
        try? await saveToCache(items)
        return items
    } catch {
        return try await loadFromCache()
    }
}

// Layered cache strategy
func load() async throws -> [Item] {
    // Layer 1: Memory cache (fastest)
    if let cached = memoryCache.get() {
        return cached
    }

    // Layer 2: Disk cache
    if let cached = try? await diskCache.get() {
        memoryCache.set(cached)
        return cached
    }

    // Layer 3: Remote API
    let items = try await remote.fetch()
    memoryCache.set(items)
    try? await diskCache.save(items)
    return items
}
```

---

## Performance Patterns

### Lazy Initialization

Don't create objects until they're actually needed.

```swift
// BAD: Eager initialization
final class AppCoordinator {
    let homeVC = HomeViewController()           // Created immediately
    let settingsVC = SettingsViewController()   // May never be used
}

// GOOD: Lazy initialization
final class AppCoordinator {
    private lazy var homeVC: HomeViewController = {
        HomeViewController()
    }()

    private lazy var settingsVC: SettingsViewController = {
        SettingsViewController(config: loadSettingsConfig())
    }()

    func showSettings() {
        present(settingsVC)  // Created only when called
    }
}
```

### Debounce & Throttle

```
User Input:   ─●─●─●─────●─●─●─●─────●─────────
Debounce:     ─────────●───────────●─────────●  (fires after pause)
Throttle:     ─●───────●───●───────●─────────●  (fires at intervals)
```

```swift
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var results: [SearchResult] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Debounce: Wait 300ms after user stops typing
        $searchText
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

**Use cases:**
- **Debounce**: Search input, form validation, auto-save
- **Throttle**: Scroll events, resize events, analytics logging

### Idempotency

Executing the same operation multiple times should produce the same result as executing it once.

```swift
// BAD: Non-idempotent - each call creates a new order
func createOrder(items: [Item]) async throws -> Order {
    let order = Order(id: UUID(), items: items)
    try await api.post(order)
    return order
}
// Network timeout, client retries → Multiple orders created!

// GOOD: Idempotent - use client-generated ID
func createOrder(
    idempotencyKey: UUID,
    items: [Item]
) async throws -> Order {
    let order = Order(id: idempotencyKey, items: items)
    return try await api.post(order, idempotencyKey: idempotencyKey)
}
// Multiple calls with same key → Only one order created
```

**Use cases:**
- Payment processing (avoid double charges)
- Order submission (avoid duplicate orders)
- Message sending (avoid duplicate messages)
