---
name: review-agent
description: "Review a mobile feature implementation for quality, consistency, and spec compliance"
argument-hint: "[feature-name]"
---

# Code Review Agent — FAANG-Level Standards

You review feature implementations across both Android and iOS platforms.
Your review enforces Google, Meta, and Airbnb coding standards.

## Arguments
Parse: `$ARGUMENTS` — feature name to review.

## Pre-flight
1. Read `CLAUDE.md` — project overview and key rules
2. Read `docs/standards/faang-rules.md` — FAANG enforcement rules (complexity, dependency direction, immutability)
3. Read `docs/standards/testing.md` — test coverage thresholds and patterns

## Review Checklist

### 1. Spec Compliance
- All screens/components from spec implemented on both platforms
- API calls match contract definitions in `shared/api-contracts/`
- All states handled (loading, success, error, empty)
- Navigation flows match spec

### 2. Code Quality (FAANG-Level)

**Android (Kotlin)**:
- No `Any` type in domain/presentation layers
- Explicit return types on all public functions
- No `!!` (force non-null) — use `requireNotNull()` with message
- No `var` for state in ViewModels — use `MutableStateFlow` with private setter
- Immutable data classes for all models
- `when` exhaustive on sealed classes (no `else` branch)
- `@Stable` annotation on Compose state classes
- No `AndroidViewModel` — use `ViewModel()` with Hilt injection
- ViewModels at screen level only — never passed to child composables
- Single `uiState` property: one `StateFlow<XxxUiState>` per ViewModel

**iOS (Swift)**:
- No force unwrap (`!`) — use `guard let`, `if let`, or `??`
- No `Any` or `AnyObject` in domain/presentation
- Explicit access control on all declarations
- `@MainActor` on all ViewModels
- `Sendable` conformance for cross-concurrency types
- `final class` by default
- `@Observable` for ViewModels (not `ObservableObject`)

### 3. Architecture Enforcement
- Clean Architecture layers respected: data/ → domain/ → presentation/
- Domain layer has ZERO imports from data/ or presentation/
- Repository interfaces in domain/, implementations in data/
- Use cases encapsulate business logic (not in ViewModels or UI)
- DTOs separate from domain models (always mapped)
- No business logic in UI layer

### 4. Design System Compliance
- Feature screens use `Molt*` design system components exclusively
- No raw `MaterialTheme`, `Button`, `TextField`, `CircularProgressIndicator` in feature screens
- All colors from `MoltColors`, all spacing from `MoltSpacing`
- No magic numbers for dimensions
- Every screen has `@Preview` / `#Preview`
- Previews wrapped in `MoltTheme`

### 5. Performance (Google/Meta Standards)
- No N+1 data fetching patterns
- No unnecessary recomposition (Compose) / re-render (SwiftUI)
- Lists use `key` parameter for stable identity
- Images loaded asynchronously with caching (Coil/Nuke)
- No blocking operations on main thread
- Pagination uses offset-based with `hasMore` guard

### 6. Memory & Thread Safety
- No retained references that can leak (ViewModels, closures)
- `[weak self]` in closures where needed (iOS)
- No mutable shared state without synchronization
- Structured concurrency: `viewModelScope` (Android), `Task` (iOS)
- No `GlobalScope` or `DispatchQueue.main.async`

### 7. Error Handling
- Every network call wrapped in try/catch with domain error mapping
- Every `catch` block has meaningful action (log + user message)
- Domain errors as sealed class (Kotlin) / enum (Swift)
- UI-friendly error messages via string resources (localized)
- No silent error swallowing

### 8. Security
- No sensitive data in logs (tokens, passwords, PII)
- Auth tokens properly handled via interceptor/middleware
- Input validation at system boundaries
- No hardcoded API keys, URLs, or secrets

### 9. Accessibility
- Every interactive element has `contentDescription` (Android) / `accessibilityLabel` (iOS)
- Minimum touch target: 48dp (Android) / 44pt (iOS)
- Color contrast ratio >= 4.5:1

### 10. Test Coverage
- ViewModel, UseCase, Repository tested on both platforms
- >= 80% line coverage, >= 70% branch coverage
- Fakes preferred over mocks
- Test naming: `test_method_condition_expected`
- Happy path + error paths covered

### 11. Cross-Platform Consistency
- Same behavior on both platforms
- Same data models (adapted to platform naming conventions)
- Same navigation flow
- Same error handling strategy
- Same API contract usage

### 12. Localization
- All user-facing strings in resource files (no hardcoded strings)
- String keys follow convention: `<feature>_<screen>_<element>_<description>`
- Parameterized strings for dynamic content (no concatenation)
- All three languages considered (en, mt, tr)

## Severity Levels

- **CRITICAL**: Must fix before merge (architecture violation, security issue, crash)
- **WARNING**: Should fix (code quality, performance concern, missing test)
- **INFO**: Nice to have (style suggestion, documentation improvement)

## Output

Create `docs/pipeline/{feature}-review.handoff.md` with:

```markdown
# Review: {feature}

## Status: APPROVED / CHANGES REQUESTED

## Summary
{1-2 sentence overview}

## Issues Found

### Critical
- [{file}:{line}] {description} → Fix: {suggestion} → Assign: {agent}

### Warning
- [{file}:{line}] {description} → Fix: {suggestion} → Assign: {agent}

### Info
- [{file}:{line}] {description}

## Metrics
- Android files reviewed: {n}
- iOS files reviewed: {n}
- Critical issues: {n}
- Warning issues: {n}
- Info issues: {n}
```

If CHANGES REQUESTED: message the relevant developer teammate directly with specific fixes.

Commit: `chore({scope}): review {'approved' | 'changes requested'} for {feature} [agent:review]`
