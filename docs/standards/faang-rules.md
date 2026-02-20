# FAANG-Level Enforcement Rules

> **Note:** These rules are enforced by lint configs, architecture tests, and CI/CD pipelines. Violations block merge.

These rules are enforced by lint configs (`detekt.yml`, `.swiftlint.yml`), architecture tests
(`ArchitectureTest.kt`, `ArchitectureTests.swift`), and CI/CD pipelines. Violations block merge.

---

## Complexity Budget

| Metric | Limit | Enforced By |
|--------|-------|-------------|
| Cyclomatic complexity | <= 10 per function | detekt / SwiftLint |
| Function body length | <= 60 lines | detekt / SwiftLint |
| File length | <= 400 lines | detekt / SwiftLint |
| Method parameters | <= 6 | detekt / SwiftLint |
| Line length | <= 120 characters | ktlint / SwiftLint |

## Zero Dead Code Policy

- Zero unused imports, variables, functions, or parameters
- No commented-out code blocks
- No `TODO` comments without linked GitHub issue
- No unreachable code paths

## Dependency Direction Enforcement

Enforced by `ArchitectureTest.kt` (Android) and `ArchitectureTests.swift` (iOS):

```
presentation/ → domain/ → (nothing)
data/ → domain/ → (nothing)
presentation/ ✗ data/  (forbidden)
domain/ ✗ data/         (forbidden)
domain/ ✗ presentation/ (forbidden)
```

- Domain layer: ZERO imports from `data/` or `presentation/`
- Presentation layer: ZERO imports from `data/`
- ViewModels: No `android.content.Context` or `android.app.*` imports (Android)
- ViewModels: Must have `@MainActor` and `@Observable` (iOS)
- Feature screens: Must use `Molt*` components, no raw Material 3 / SwiftUI

## API Safety

- All network calls wrapped in `try/catch` with domain error mapping
- Never swallow exceptions — every `catch` has a meaningful action (log + user message)
- Domain errors as sealed class (Kotlin) / enum (Swift)
- No hardcoded API URLs, keys, or secrets
- Auth tokens via interceptor/middleware only

## Immutability Rules

- All domain models are immutable (`data class` / `struct`)
- No `var` for state in ViewModels — use `MutableStateFlow` (Android) / `@Observable` (iOS)
- All DTOs are immutable
- Collections exposed as `List` (Kotlin) / `[T]` (Swift), never mutable

## Naming Discipline

- Intention-revealing names — no abbreviations (`productListViewModel`, not `plvm`)
- No single-letter variables except lambdas (`it`, `$0`)
- No Hungarian notation
- Follow platform naming conventions strictly (see Naming Conventions table)

## Design System Compliance

- Feature screens: `Molt*` components ONLY (no raw `Button`, `TextField`, `ProgressView`)
- All colors from `MoltColors` — no hardcoded hex values in feature code
- All spacing from `MoltSpacing` — no magic numbers for dimensions
- Every screen composable has `@Preview` / `#Preview` wrapped in `MoltTheme`
