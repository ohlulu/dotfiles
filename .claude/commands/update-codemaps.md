# Update Codemaps

Analyze the codebase structure and update architecture documentation.

## Project Detection

First, detect the project type:

### Swift/iOS Project (if Package.swift, .xcodeproj, or .xcworkspace exists)
- Use SourceKitten for AST analysis: `sourcekitten structure --file <file>`
- Use dependency-graph for dependencies: `dependency-graph Package.swift --syntax mermaid`
- Use SPM: `swift package show-dependencies --format json`

### TypeScript/Node.js Project (if package.json exists)
- Scan imports/exports from source files
- Parse package.json for dependencies

## Codemap Generation

1. Scan all source files for:
   - **Swift**: imports, protocols, classes, structs, enums, @main entry points
   - **TypeScript**: imports, exports, interfaces, classes, dependencies

2. Generate token-lean codemaps:

   **Swift Project Structure:**
   - docs/CODEMAPS/INDEX.md - Overview of all areas
   - docs/CODEMAPS/app.md - App structure, entry points (@main, AppDelegate)
   - docs/CODEMAPS/features.md - Feature modules
   - docs/CODEMAPS/services.md - Services layer (Network, Persistence)
   - docs/CODEMAPS/models.md - Data models
   - docs/CODEMAPS/persistence.md - Core Data, SwiftData, UserDefaults
   - docs/CODEMAPS/networking.md - API clients, network layer

   **TypeScript Project Structure:**
   - docs/CODEMAPS/architecture.md - Overall architecture
   - docs/CODEMAPS/backend.md - Backend structure
   - docs/CODEMAPS/frontend.md - Frontend structure
   - docs/CODEMAPS/data.md - Data models and schemas

3. Calculate diff percentage from previous version
4. If changes > 30%, request user approval before updating
5. Add freshness timestamp (Last Updated: YYYY-MM-DD) to each codemap
6. Save reports to .reports/codemap-diff.txt

## Codemap Format

```markdown
# [Area] Codemap

**Last Updated:** YYYY-MM-DD
**Framework:** SwiftUI / UIKit / React / Next.js
**Entry Points:** list of main files

## Architecture

[ASCII diagram or Mermaid diagram of component relationships]

## Key Types

| Type | Kind | Purpose | Dependencies |
|------|------|---------|--------------|
| ... | ... | ... | ... |

## Data Flow

[Description of how data flows through this area]

## External Dependencies

- Package/Framework - Purpose, Version

## Related Areas

Links to other codemaps that interact with this area
```

Focus on high-level structure, not implementation details. Keep each codemap under 500 lines.
