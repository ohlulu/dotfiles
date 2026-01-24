# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

### Planning & Documentation

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring, architectural changes |
| doc-updater | TypeScript/JS documentation | Updating codemaps and docs for TS/JS projects |
| swift-doc-updater | Swift/iOS documentation | Updating codemaps and docs for Swift projects |

### TDD (Test-Driven Development)

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| ts-tdd-guide | TypeScript/JS TDD | New TS/JS features, bug fixes (Jest, Vitest, Playwright) |
| swift-tdd-guide | Swift TDD | New Swift features, bug fixes (XCTest, Swift Testing) |

### Build Error Resolution

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| ts-build-error-resolver | TypeScript/JS build errors | npm/yarn build fails, tsc errors, Next.js compilation |
| swift-build-error-resolver | Swift build errors | swift build fails, xcodebuild errors, SPM issues |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests → Use **planner** agent
2. TypeScript/JS bug fix or new feature → Use **ts-tdd-guide** agent
3. Swift bug fix or new feature → Use **swift-tdd-guide** agent
4. `npm run build` fails → Use **ts-build-error-resolver** agent
5. `swift build` fails → Use **swift-build-error-resolver** agent
6. Documentation needs update → Use **doc-updater** or **swift-doc-updater**

## Language-Specific Agent Selection

```
TypeScript/JavaScript Project:
├── TDD → ts-tdd-guide
├── Build errors → ts-build-error-resolver
└── Documentation → doc-updater

Swift/iOS Project:
├── TDD → swift-tdd-guide
├── Build errors → swift-build-error-resolver
└── Documentation → swift-doc-updater
```

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: ts-tdd-guide for feature A
2. Agent 2: swift-tdd-guide for feature B
3. Agent 3: doc-updater for documentation

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```
