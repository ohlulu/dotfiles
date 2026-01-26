# Development Principles

## General Principles

### YAGNI (You Aren't Gonna Need It)

- Only implement features that are needed **right now**
- Never build for "we might need this later"
- Delete speculative code ruthlessly

### Fail Fast

- Errors should surface as early as possible
- Use `guard` and `assert` for precondition checks
- Crash early in development; handle gracefully in production

### Make It Work, Make It Right, Make It Fast

1. **Work** - Get the feature functioning correctly
2. **Right** - Refactor into clean, maintainable code
3. **Fast** - Optimize performance only if necessary

### Premature Optimization Is the Root of All Evil

- Measure first, optimize second
- No profiling data = no optimization
- Readable code beats "clever" code

### Single Responsibility

A module should have one, and only one, reason to change.

```swift
// BAD: Multiple responsibilities in one class
final class ProductViewController: UIViewController {
    func loadProducts() {
        // Networking logic
        URLSession.shared.dataTask(with: url) { data, _, _ in
            // Parsing logic
            let products = try? JSONDecoder().decode([Product].self, from: data!)
            // UI logic
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
}

// GOOD: Separated responsibilities
final class ProductLoader {
    func load() async throws -> [Product] { /* networking */ }
}

final class ProductMapper {
    static func map(_ data: Data) throws -> [Product] { /* parsing */ }
}

@MainActor
final class ProductViewController: UIViewController {
    func display(_ products: [Product]) { /* UI only */ }
}
```

### Dependency Inversion

High-level modules should not depend on low-level modules. Both should depend on abstractions.

```
┌─────────────────────────────────┐
│      Composition Root           │  ← Only place that knows all implementations
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│         UI Layer                │  ← Only knows Presenter protocols
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│      Business Logic Layer       │  ← Only knows Repository protocols
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│      Infrastructure Layer       │  ← Implements protocols, not depended upon
└─────────────────────────────────┘
```

**Dependency Rules:**
- Domain → Zero dependencies
- Usecases → Only depends on Domain
- Presentation → Depends on Domain + Usecases
- Infrastructure → Implements Domain-defined protocols
- Composition Root → Only place that knows all concrete types

**Common Mistakes:**
- ViewController directly imports CoreData
- Domain Model contains `@Published` or Combine
- Business logic directly calls `URLSession`

### Command-Query Separation

A method should either change state (command) or return data (query), never both.

```swift
// BAD: Method both mutates and returns
func popAndReturn() -> Item? {
    return items.removeLast()  // Mutation + return
}

// GOOD: Separate query (no side effects)
func peek() -> Item? {
    items.last
}

// GOOD: Separate command (only side effects)
func pop() {
    items.removeLast()
}
```

**Exception:** Performance-critical atomic operations (e.g., `fetchAndIncrement`).

---

## Swift Type Design Principles

### Make Illegal States Unrepresentable

Use Swift's type system to prevent invalid data at compile time, not runtime.

```swift
// BAD: Boolean + Optional creates contradictory states
var trackStock: Bool        // true
var stockQuantity: Int?     // nil  ← contradiction!

// GOOD: Enum with associated values
enum StockTracking {
    case notTracked
    case tracked(quantity: Int, lowStockThreshold: Int?)
}
```

### Single Source of Truth

Avoid redundant fields that can become inconsistent. Derive values via computed properties.

```swift
// BAD: Redundant boolean flags
var required: Bool       // true
var minSelection: Int    // 0  ← contradiction!
var allowMultiple: Bool  // false
var maxSelection: Int?   // 5  ← contradiction!

// GOOD: Single source with computed properties
struct SelectionRule {
    var minSelection: Int
    var maxSelection: Int?

    var isRequired: Bool { minSelection > 0 }
    var allowsMultiple: Bool { maxSelection != 1 }
}
```

### Explicit Variant Combinations

For products with multiple option dimensions (color, size), don't assume all combinations exist.

```swift
// BAD: Implicit full matrix (assumes all 12 combinations: 3 colors × 4 sizes)
var colors: [String]
var sizes: [String]

// GOOD: Explicit valid combinations
var optionGroups: [OptionGroup]
var variants: [Variant]  // Only variants that actually exist

struct Variant {
    var selectedOptions: [UUID]  // References to specific Option IDs
    var price: Decimal
    var stockQuantity: Int?
}
```

### Group Related Properties

When multiple fields are only meaningful together, encapsulate them.

```swift
// BAD: Scattered related fields
var taxable: Bool
var taxRate: Decimal?

// GOOD: Encapsulated configuration
enum TaxConfiguration {
    case notTaxable
    case taxable(rate: Decimal)
}
```

### Prefer Composition Over Flags

Instead of adding boolean flags for every feature, use optional nested types.

```swift
// BAD: Mix of flags and optionals
var trackStock: Bool
var stockQuantity: Int?

// GOOD: Stock info is either fully present or absent
var stock: StockTracking  // .notTracked or .tracked(...)
```

### Immutability First

Default to `let` and `struct`. Mutability is the exception, requiring explicit justification.

```swift
// GOOD: Immutable domain model
struct Order: Hashable, Sendable {
    let id: UUID
    let items: [OrderItem]
    let totalAmount: Decimal
    let createdAt: Date
}

// When modification needed, create new instance
func updateOrder(_ order: Order, newItems: [OrderItem]) -> Order {
    Order(
        id: order.id,
        items: newItems,
        totalAmount: calculateTotal(newItems),
        createdAt: order.createdAt
    )
}
```

**Derived Data via Computed Properties:**

```swift
struct OrderViewModel {
    let order: Order

    var formattedTotal: String { "$\(order.totalAmount)" }
    var itemCount: Int { order.items.count }
    var isEmpty: Bool { order.items.isEmpty }
}
```

---

## Swift Concurrency Principles

### Default Actor Isolation per Target

Configure Default Actor Isolation in Xcode's build settings per target. The compiler automatically infers `@MainActor` for all types unless explicitly opted out.

**Guidelines:**
- **UI modules** (e.g., iOS UI target) → Default to `@MainActor` to keep UI code single-threaded
- **Non-UI or mixed modules** → Default to `nonisolated`, mark specific types/methods as `@MainActor` when needed

```
┌─────────────────────────────────────────────────────────┐
│  Target Type         │  Default Actor Isolation        │
├─────────────────────────────────────────────────────────┤
│  iOS UI Target       │  @MainActor                     │
│  Domain/Core Module  │  nonisolated                    │
│  Networking Module   │  nonisolated                    │
│  Shared Utils        │  nonisolated                    │
└─────────────────────────────────────────────────────────┘
```

### XCTestCase Classes Must Be @MainActor

Mark test case classes as `@MainActor` to preserve XCTest's default behavior of running on the main thread. This eliminates warnings during Swift 6 migration and keeps tests behaving as expected.

```swift
// GOOD: Explicit @MainActor on test class
@MainActor
final class ProductViewModelTests: XCTestCase {
    func test_loadProducts_updatesState() async {
        let sut = makeSUT()
        // Test runs on main thread as expected
    }
}
```

### Avoid Unsafe Concurrency Escape Hatches

**Never use** `nonisolated(unsafe)` or `@unchecked Sendable` unless absolutely necessary. These bypass the compiler's concurrency safety checks and can introduce data races.

```swift
// BAD: Bypassing safety checks
nonisolated(unsafe) var sharedState: [String] = []

final class UnsafeWrapper: @unchecked Sendable {
    var mutableData: Data  // Data race waiting to happen
}

// GOOD: Proper thread-safe design
actor SafeState {
    private var items: [String] = []

    func append(_ item: String) {
        items.append(item)
    }
}

// GOOD: Immutable Sendable
struct SafeWrapper: Sendable {
    let data: Data  // Immutable, safe to share
}
```

**If you must use escape hatches:**
1. Document why it's necessary
2. Ensure thread safety through other means (locks, queues)
3. Isolate usage to minimal scope
4. Add code review requirement for these patterns
