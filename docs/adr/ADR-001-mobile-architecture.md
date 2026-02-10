# ADR-001: Mobile App Architecture Decisions

## Status
Accepted

## Date
2026-02-10

## Context
Molt Marketplace needs native mobile buyer applications for both Android and iOS. The backend is built on Medusa v2.13.1 with REST APIs. We need to decide on:
1. Technology stack for each platform
2. App architecture pattern
3. Development orchestration approach
4. How to maintain consistency across platforms

## Decision

### Technology Stack
- **Android**: Kotlin 2.1+ with Jetpack Compose, Material 3, Hilt DI, Retrofit + OkHttp
- **iOS**: Swift 6+ with SwiftUI, manual DI (protocol-based), URLSession + async/await
- **Rationale**: Both use declarative UI frameworks (Compose/SwiftUI) which enables similar architecture patterns and makes AI-generated code more predictable and consistent.

### Architecture: Clean Architecture
- **Data Layer**: DTOs, API services, repository implementations, local storage
- **Domain Layer**: Use cases, domain models, repository interfaces
- **Presentation Layer**: ViewModels, UI state, Views/Composables
- **Rationale**: Clear separation of concerns, testable at each layer, platform-agnostic business logic.

### Orchestration: Claude Code Agent Teams (built-in)
- Built-in multi-agent feature of Claude Code (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`)
- Team lead coordinates 7 specialized teammates: Architect, Android Dev, iOS Dev, Android Tester, iOS Tester, Doc, Reviewer
- Parallel Android + iOS development via shared task list with dependency tracking
- Teammates communicate directly (e.g., reviewer sends fixes to developer)
- Zero custom orchestration code — all configuration via CLAUDE.md and skills
- **Rationale**: Built-in feature requires no external code, provides native parallel execution, shared task management, inter-agent messaging, and automatic CLAUDE.md loading for all teammates.

### Cross-Platform Consistency
- Platform-agnostic feature specs (architect output)
- Shared API contracts (`shared/api-contracts/`)
- Shared design tokens (`shared/design-tokens/`)
- Cross-platform reviewer agent ensures behavioral consistency
- iOS developer references Android implementation for consistency

## Consequences

### Positive
- Declarative UI on both platforms enables similar code patterns
- Clean Architecture provides clear boundaries for testing and maintenance
- Parallel development reduces per-feature time by ~40%
- Shared specs and contracts ensure consistency
- Agent pipeline automates the full development lifecycle

### Negative
- Two native codebases means double the code vs cross-platform (Flutter/RN)
- Agent Teams is experimental with known limitations (no session resumption, task status can lag)
- Build verification requires platform tooling (Android SDK, Xcode)
- Higher API cost per feature (~$13-22 vs ~$10 for backend) due to separate teammate context windows

### Alternatives Considered
1. **Flutter/React Native** — Rejected: Less native feel, fewer AI training examples, single-platform bugs harder to debug
2. **Kotlin Multiplatform (KMP)** — Rejected: Still maturing, complex setup, SwiftUI integration not seamless
3. **claude -p pipeline (like backend)** — Viable but lacks inter-agent communication and shared task management
4. **Claude Agent SDK (TypeScript)** — Rejected: Unnecessary overhead; `query()` is essentially a programmatic wrapper around `claude -p`. Agent Teams provides the same capabilities built-in with zero custom code
