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

---

## Swift Type Design Principles

### 1. Make Illegal States Unrepresentable

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

### 2. Single Source of Truth

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

### 3. Explicit Variant Combinations

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

### 4. Group Related Properties

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

### 5. Prefer Composition Over Flags

Instead of adding boolean flags for every feature, use optional nested types.

```swift
// BAD: Mix of flags and optionals
var trackStock: Bool
var stockQuantity: Int?

// GOOD: Stock info is either fully present or absent
var stock: StockTracking  // .notTracked or .tracked(...)
```
