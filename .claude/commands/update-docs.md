# Update Documentation

Sync documentation from source-of-truth.

## Project Detection

First, detect the project type:

### Swift/iOS Project (if Package.swift, .xcodeproj, or .xcworkspace exists)
- Source of truth: Package.swift, Info.plist, .xcconfig files
- Use SourceDocs for API documentation: `sourcedocs generate --all-modules --output-folder docs/API`

### TypeScript/Node.js Project (if package.json exists)
- Source of truth: package.json, .env.example

## Documentation Tasks

### 1. Extract Configuration

- Read Package.swift for dependencies and targets
- Read Info.plist for app configuration
- Read .xcconfig files for build settings
- Extract minimum iOS/macOS version requirements

### 2. Environment Variables

- Read Config.example.swift or similar
- Document xcconfig variables
- List required API keys and configuration

### 3. Generate docs/CONTRIB.md

- Requirements (Xcode version, iOS/macOS minimum, Swift version)
- Clone and setup instructions
- Build commands (`swift build`, `xcodebuild`)
- Testing procedures (`swift test`, Cmd+U)
- Code style guidelines

### 4. Generate docs/RUNBOOK.md

- App Store submission procedures
- TestFlight distribution
- Common build issues and fixes
- Certificate/provisioning troubleshooting

### 5. Update README.md

```markdown
# Project Name

Brief description

## Requirements
- iOS X.X+ / macOS X.X+
- Xcode X.X+
- Swift X.X+

## Installation
git clone / open .xcodeproj / swift package resolve

## Architecture
See docs/CODEMAPS/INDEX.md

## Testing
swift test / Cmd+U
```

### 6. Identify Obsolete Documentation

- Find docs not modified in 90+ days
- Check for references to deleted files
- List for manual review

### 7. Show Diff Summary

Display changes made to documentation files.

## Quality Checks

- [ ] All mentioned file paths exist
- [ ] All links work (internal and external)
- [ ] Code examples compile/run
- [ ] Version numbers are current
- [ ] No obsolete references
