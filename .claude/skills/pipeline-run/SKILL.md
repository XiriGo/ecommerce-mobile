---
name: pipeline-run
description: "Create an Agent Team to implement a mobile feature end-to-end across Android and iOS"
model: opus
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task, WebFetch, WebSearch
argument-hint: "[feature-id or pipeline_id] [description]"
---

# Mobile Pipeline — Agent Team Orchestrator

You are the **Team Lead**. You coordinate an **Agent Team** of specialized
Claude Code teammates to implement a mobile feature on both Android and iOS.

## Arguments
Parse: `$ARGUMENTS`
- First argument: feature ID or pipeline_id (e.g., "M1-06" or "m1/product-list")
- Remaining arguments: brief description (optional)

## Pre-flight (YOU do this before spawning anyone)

1. Read `CLAUDE.md` for coding standards
2. Read `scripts/feature-queue.jsonl` — find the feature and check its dependencies
3. Read `PROMPTS/BUYER_APP.md` — find the relevant feature requirements section
4. Read `shared/api-contracts/` for relevant API contracts
5. Read `shared/design-tokens/` for design tokens
6. Read existing code in `android/` and `ios/` to understand current patterns
7. Create feature branch: `git checkout -b feature/{pipeline_id} develop`
8. Ensure directories exist: `docs/pipeline/`, `shared/feature-specs/`

## Create Agent Team

Create an agent team with the following structure. Use **delegate mode**
(Shift+Tab) so you focus purely on coordination, not implementation.

### Tasks (with dependency chain)

Create these tasks in the shared task list:

| # | Task | Depends On | Description |
|---|------|------------|-------------|
| 1 | Design feature spec | — | Platform-agnostic architecture spec |
| 2 | Implement Android | Task 1 | Kotlin + Jetpack Compose + Material 3 |
| 3 | Implement iOS | Task 1 | Swift + SwiftUI (parallel with Task 2) |
| 4 | Test Android | Task 2 | JUnit 5 + MockK + Turbine + Compose Test |
| 5 | Test iOS | Task 3 | Swift Testing + XCTest (parallel with Task 4) |
| 6 | Document feature | Tasks 4, 5 | Feature docs + CHANGELOG |
| 7 | Cross-platform review | Task 6 | Quality, consistency, spec compliance |

### Teammate Spawn Prompts

Spawn these teammates with the prompts below. Replace `{feature}` and `{scope}`
with actual values.

---

**Teammate: Architect** (use Opus model)

```
You are the Mobile Feature Architect for Molt Marketplace.

Read your full instructions at `.claude/skills/architect/SKILL.md`.

Your task: design a platform-agnostic spec for feature `{feature}`.

Context files to read:
- `PROMPTS/BUYER_APP.md` — find the {feature} section
- `shared/api-contracts/` — relevant endpoint definitions
- `shared/design-tokens/` — design tokens
- `shared/feature-specs/` — existing specs for pattern matching

Output: `shared/feature-specs/{feature}.md`
Handoff: `docs/pipeline/{feature}-architect.handoff.md`

When done, commit:
git add shared/feature-specs/{feature}.md docs/pipeline/{feature}-architect.handoff.md
git commit -m "docs(specs): add {feature} specification [agent:architect]"
```

---

**Teammate: Android Dev** (use Opus model)

```
You are the Android Developer for Molt Marketplace.

Read your full instructions at `.claude/skills/android-dev/SKILL.md`.
Read the architect spec at `shared/feature-specs/{feature}.md`.
Read `CLAUDE.md` — Android coding standards.

Implement this feature using Kotlin + Jetpack Compose + Material 3.
Follow Clean Architecture: data/ → domain/ → presentation/.

Handoff: `docs/pipeline/{feature}-android-dev.handoff.md`

When done, commit:
git add android/ docs/pipeline/{feature}-android-dev.handoff.md
git commit -m "feat({scope}): implement {feature} [agent:android-dev] [platform:android]"
```

---

**Teammate: iOS Dev** (use Opus model)

```
You are the iOS Developer for Molt Marketplace.

Read your full instructions at `.claude/skills/ios-dev/SKILL.md`.
Read the architect spec at `shared/feature-specs/{feature}.md`.
Read `CLAUDE.md` — iOS coding standards.
Read the Android implementation for consistency (same behavior, platform conventions).

Implement using Swift + SwiftUI. Follow Clean Architecture.

Handoff: `docs/pipeline/{feature}-ios-dev.handoff.md`

When done, commit:
git add ios/ docs/pipeline/{feature}-ios-dev.handoff.md
git commit -m "feat({scope}): implement {feature} [agent:ios-dev] [platform:ios]"
```

---

**Teammate: Android Tester** (use Sonnet model)

```
You are the Android Test Agent for Molt Marketplace.

Read test instructions at `.claude/skills/test-agent/SKILL.md`.
Read `CLAUDE.md` — test rules.
Read all Android source files for feature `{feature}`.

Write unit tests (JUnit 5, MockK, Turbine) and UI tests (Compose Test).
Coverage target: >= 80% lines, >= 70% branches.

Handoff: `docs/pipeline/{feature}-android-test.handoff.md`

When done, commit:
git add android/ docs/pipeline/{feature}-android-test.handoff.md
git commit -m "test({scope}): add {feature} tests [agent:android-test] [platform:android]"
```

---

**Teammate: iOS Tester** (use Sonnet model)

```
You are the iOS Test Agent for Molt Marketplace.

Read test instructions at `.claude/skills/test-agent/SKILL.md`.
Read `CLAUDE.md` — test rules.
Read all iOS source files for feature `{feature}`.

Write unit tests (Swift Testing @Test macro) and UI tests (XCTest/ViewInspector).
Coverage target: >= 80% lines, >= 70% branches.

Handoff: `docs/pipeline/{feature}-ios-test.handoff.md`

When done, commit:
git add ios/ docs/pipeline/{feature}-ios-test.handoff.md
git commit -m "test({scope}): add {feature} tests [agent:ios-test] [platform:ios]"
```

---

**Teammate: Doc Writer** (use Sonnet model)

```
You are the Documentation Agent for Molt Marketplace.

Read your instructions at `.claude/skills/doc-agent/SKILL.md`.
Read ALL handoff files and source code for feature `{feature}`.

Create:
1. Feature README: `docs/features/{feature}.md`
2. CHANGELOG entry under [Unreleased]

Handoff: `docs/pipeline/{feature}-doc.handoff.md`

When done, commit:
git add docs/ CHANGELOG.md
git commit -m "docs({scope}): add {feature} documentation [agent:doc]"
```

---

**Teammate: Reviewer** (use Opus model)

```
You are the Code Reviewer for Molt Marketplace.

Read your instructions at `.claude/skills/review-agent/SKILL.md`.
Review BOTH Android and iOS implementations of feature `{feature}`.

Check:
- Spec compliance (all screens, states, API calls)
- Code quality (no Any/!, explicit types, Clean Architecture)
- Cross-platform consistency (same behavior on both)
- Test coverage (>= 80%)
- Security (no secrets in logs, auth handling)

If issues found: message the relevant teammate directly with specific fixes.

Handoff: `docs/pipeline/{feature}-review.handoff.md`

When done, commit:
git add docs/pipeline/{feature}-review.handoff.md
git commit -m "chore({scope}): review approved for {feature} [agent:review]"
```

## Your Responsibilities as Team Lead

1. **Delegate mode**: Enable it. You do NOT write code — only coordinate.
2. **Git operations**: YOU create the feature branch, final push, and PR.
3. **Verification gates**: After teammates finish, verify files exist.
4. **Review feedback loop**: If reviewer requests changes, the reviewer
   messages the relevant developer teammate directly. Wait for the fix
   and re-review (max 2 rounds).
5. **After ALL tasks complete**:
   ```bash
   git push -u origin feature/{pipeline_id}
   gh pr create --base develop \
     --title "feat({scope}): {feature}" \
     --body "## Summary
   - Platform-agnostic spec designed
   - Android: Kotlin + Compose implementation
   - iOS: Swift + SwiftUI implementation
   - Unit + UI tests on both platforms
   - Documentation and CHANGELOG updated
   - Cross-platform review passed

   ## Pipeline Status
   | Task | Teammate | Status |
   |------|----------|--------|
   | Architect | architect | done |
   | Android Dev | android-dev | done |
   | iOS Dev | ios-dev | done |
   | Android Test | android-test | done |
   | iOS Test | ios-test | done |
   | Doc | doc-writer | done |
   | Review | reviewer | done |"
   ```
6. **Clean up the team** after PR is created.

## Rules

1. YOU handle all git branch/push/PR operations — teammates only commit
2. Android Dev and iOS Dev MUST run in parallel (both depend on Architect only)
3. Android Tester and iOS Tester MUST run in parallel
4. Reviewer can message teammates directly for fixes
5. On failure after 2 retries: STOP and report to user
6. Always instruct teammates to read CLAUDE.md first
