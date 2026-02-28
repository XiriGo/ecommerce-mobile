# CLAUDE.md - XiriGo Ecommerce Mobile App

## Project Identity

- **Project**: XiriGo Ecommerce - Mobile Buyer App
- **Platforms**: Native Android + Native iOS
- **Android**: Kotlin + Jetpack Compose + Material 3
- **iOS**: Swift + SwiftUI
- **Architecture**: Clean Architecture (Data → Domain → Presentation)
- **Backend**: Medusa v2 REST API (base URL from environment)
- **Package Manager**: Gradle KTS (Android), SPM (iOS)

## Architecture

### Clean Architecture Layers

Each feature follows three layers:

1. **Data Layer**: Repository implementations, API DTOs, mappers, local storage
2. **Domain Layer**: Use cases, domain models, repository interfaces (protocols/interfaces)
3. **Presentation Layer**: UI components (Compose/SwiftUI), ViewModels, UI state models

### Feature Module Structure

```
# Android: android/app/src/main/java/com/xirigo/ecommerce/feature/<name>/
# iOS:     ios/XiriGoEcommerce/Feature/<Name>/

feature/<name>/
  ├── data/
  │   ├── dto/           # API request/response DTOs
  │   ├── mapper/        # DTO ↔ Domain model mappers
  │   ├── remote/        # API service interface
  │   └── repository/    # Repository implementation
  ├── domain/
  │   ├── model/         # Domain models
  │   ├── repository/    # Repository interface
  │   └── usecase/       # Use cases
  └── presentation/
      ├── component/     # Reusable UI components for this feature
      ├── screen/        # Screen composables/views
      ├── viewmodel/     # ViewModels
      └── state/         # UI state models
```

### Design System Layer

All UI components live in a **shared design system module** that wraps platform components.
Feature screens **NEVER** use Material 3 or SwiftUI components directly — they use `XG*` wrappers.

- **Android**: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/`
- **iOS**: `ios/XiriGoEcommerce/Core/DesignSystem/`
- **Tokens**: `shared/design-tokens/` (JSON, updated from Figma)

Components: `XGButton`, `XGCard`, `XGTextField`, `XGTopBar`, `XGBottomBar`,
`XGLoadingView`, `XGErrorView`, `XGEmptyView`, `XGImage`, `XGBadge`

**Critical Rule**: When Figma designs arrive, only `core/designsystem/` files change. Zero feature screen edits needed.

### State Management

- **Unidirectional Data Flow (UDF)**: UI → Event → ViewModel → State → UI
- Screen state as a single sealed interface/enum with Loading, Success, Error variants
- Side effects via Channel/SharedFlow (Android) or callback (iOS)

## Key Rules (All Agents)

1. **No `Any` type** in domain/presentation layers
2. **No force unwrap** (`!!` in Kotlin, `!` in Swift)
3. **Immutable models** — all data classes/structs are immutable
4. **Domain layer isolation** — zero imports from data/ or presentation/
5. **`XG*` components only** in feature screens — no raw Material 3 or SwiftUI
6. **All strings localized** — no hardcoded user-facing strings
7. **Every screen has a Preview** — `@Preview` (Android) / `#Preview` (iOS)
8. **Fakes over mocks** in tests — `Fake{Name}Repository` pattern
9. **SVG = visual reference only** — use design tokens, not hardcoded hex/pixels from SVGs
10. **Extend, don't recreate** — always check existing code before creating new files (see `docs/standards/common.md`)

## Detailed Standards (Split by Domain)

Platform-specific rules, code templates, and design system reference:

| Document | Path | Who Reads It |
|----------|------|-------------|
| Android Standards | `docs/standards/android.md` | Android Dev, Android Tester |
| iOS Standards | `docs/standards/ios.md` | iOS Dev, iOS Tester |
| Common Standards | `docs/standards/common.md` | All agents |
| Testing Standards | `docs/standards/testing.md` | Testers, Reviewer |
| FAANG Rules | `docs/standards/faang-rules.md` | Reviewer, All devs |
| Pipeline Guide | `docs/PIPELINE-GUIDE.md` | Team Lead, Queue Runner |

## Git Workflow

### Branch Naming

- `feature/m<phase>/<feature-name>` (e.g., `feature/m1/product-list`)
- `fix/m<phase>/<description>` (e.g., `fix/m1/login-validation`)

### Commit Convention

```
<type>(<scope>): <description> [agent:<name>] [platform:<android|ios|both>]
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `infra`, `chore`

### Merge Strategy

- **Feature → develop**: Squash merge (auto-merge via CI)
- **develop → main**: Merge commit
- PR body MUST include `Closes #N` to auto-close the linked GitHub issue

## GitHub Workflow

All work is tracked via **GitHub Issues** → **Milestones** → **Project Board** (Kanban).

| Milestone | Scope |
|-----------|-------|
| M0: Foundation | Scaffold, design system, network, navigation, DI, auth |
| M1: Core Features | Login, register, home, categories, products, search |
| M2: Commerce | Cart, wishlist, address, checkout, payment |
| M3: User Features | Orders, profile, payments, notifications, settings, reviews |
| M4: Enhancements | Q&A, recently viewed, price alerts, share, onboarding |

Issue lifecycle: `Backlog → Ready → In Progress → In Review → Done`

Issue map: `scripts/issue-map.json` (feature ID → GitHub issue number)

## Agent Pipeline

7 specialized agents work in sequence with parallel phases:

```
Architect → [Android Dev ‖ iOS Dev] → [Android Tester ‖ iOS Tester] → Doc → Review → Quality Gate
```

| Agent | Model | Reads |
|-------|-------|-------|
| Architect | Opus | `CLAUDE.md` + `docs/standards/common.md` |
| Android Dev | Opus | `CLAUDE.md` + `docs/standards/android.md` |
| iOS Dev | Opus | `CLAUDE.md` + `docs/standards/ios.md` |
| Android Tester | Sonnet | `CLAUDE.md` + `docs/standards/android.md` + `docs/standards/testing.md` |
| iOS Tester | Sonnet | `CLAUDE.md` + `docs/standards/ios.md` + `docs/standards/testing.md` |
| Doc Writer | Sonnet | `CLAUDE.md` |
| Reviewer | Opus | `CLAUDE.md` + `docs/standards/faang-rules.md` + `docs/standards/testing.md` |

Commands: `/pipeline-run`, `/queue-run`, `/create-feature`, `/create-pr`, `/verify`

Full pipeline documentation: `docs/PIPELINE-GUIDE.md`

## Key File Locations

### Shared (Cross-Platform)

- `CLAUDE.md` — This file (project overview)
- `PROMPTS/BUYER_APP.md` — Full buyer app requirements
- `shared/api-contracts/` — Backend API endpoint definitions
- `shared/design-tokens/` — Design system tokens (colors, typography)
- `shared/feature-specs/` — Platform-agnostic feature specifications
- `scripts/issue-map.json` — Feature ID → GitHub issue number mapping
- `docs/pipeline/` — Agent handoff files
- `docs/standards/` — Detailed coding standards (split by domain)
- `docs/PIPELINE-GUIDE.md` — Pipeline commands and workflow guide

### Android

- `android/app/src/main/java/com/xirigo/ecommerce/` — Source root
- `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/` — Design system
- `android/app/src/main/java/com/xirigo/ecommerce/feature/` — Feature modules
- `android/app/src/main/res/` — Resources (strings, drawables)
- `android/app/build.gradle.kts` — App-level Gradle configuration
- `android/config/detekt/detekt.yml` — Detekt lint rules

### iOS

- `ios/XiriGoEcommerce/` — Source root
- `ios/XiriGoEcommerce/Core/DesignSystem/` — Design system
- `ios/XiriGoEcommerce/Feature/` — Feature modules
- `ios/XiriGoEcommerce/Resources/` — Resources (localization, assets)
- `ios/Package.swift` — SPM dependencies
- `ios/.swiftlint.yml` — SwiftLint rules

## MCP Servers

| MCP Server | Scope | Purpose |
|------------|-------|---------|
| `xcode-build` | iOS | Xcode build, test, simulator |
| `apple-docs` | iOS | Apple Developer Documentation |
| `material3` | Android | Material 3 components, tokens |
| `ios-simulator` | iOS | Simulator interaction |
| `mobile-automation` | Both | ADB + Simulator automation |
| `context7` | Both | Library documentation |
| `github` | Project | GitHub API (needs `GITHUB_TOKEN`) |
| `figma` | Design | Figma API (needs `FIGMA_API_KEY`) |
| `firebase` | Both | Firebase services |

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

| Workflow | Purpose |
|----------|---------|
| `android-ci.yml` | ktlint + detekt + build + test |
| `ios-ci.yml` | SwiftLint + SwiftFormat + build + test |
| `pr-gate.yml` | Combined gate with path filtering |
| `auto-merge.yml` | Squash merge for `agent:pipeline` PRs |

Required check for merge: `pr-gate-result`

## Documentation

- Feature docs: `docs/features/<name>.md`
- API integration: `docs/api/<resource>.md`
- ADRs: `docs/adr/ADR-NNN-<title>.md`
- CHANGELOG: Updated per milestone

---

**Last Updated**: 2026-02-20
**Maintained By**: XiriGo Development Team
