---
name: pipeline-run
description: "Create an Agent Team to implement a mobile feature end-to-end across Android and iOS (SDD+TDD: Architect → ADR-Doc → Test-First → Dev → Self-Heal → Visual-Verify → Regression → Review → API-Doc)"
argument-hint: "[feature-id or pipeline_id] [description] [--issue N] [--svg XiriGo_App_XX.svg]"
---

# Mobile Pipeline — Agent Team Orchestrator

You are the **Team Lead**. You coordinate an **Agent Team** of specialized
Claude Code teammates to implement a mobile feature on both Android and iOS.

**Pipeline methodology**: SDD (Spec-Driven Development) + TDD (Test-Driven Development)
- Architect writes the spec FIRST
- ADR-Doc captures architectural decisions BEFORE tests
- Testers write tests FROM THE SPEC + ADR (tests define the contract)
- Developers write code TO PASS existing tests (NEVER modify test files)
- Self-Heal auto-fixes failures (max 2 retries)
- Visual-Verify compares screenshots with design PNGs
- Regression ensures existing tests still pass

## Arguments
Parse: `$ARGUMENTS`
- First argument: feature ID or pipeline_id (e.g., "M1-06" or "m1/product-list")
- `--issue N`: GitHub issue number to link (for progress tracking)
- `--svg XiriGo_App_XX.svg`: SVG design file name (for visual verification)
- Remaining arguments: brief description (optional)

## Pre-flight (YOU do this before spawning anyone)

1. Read `CLAUDE.md` for project overview (lean — no platform-specific details)
2. Read `scripts/issue-map.json` — find the feature's GitHub issue number
3. If `--issue N` provided, read the issue body for requirements:
   `gh issue view N --json body,title`
4. Read `PROMPTS/BUYER_APP.md` — find the relevant feature requirements section
5. Read `shared/api-contracts/` for relevant API contracts
6. Read `shared/design-tokens/` for design tokens
7. If `--svg` provided, convert to PNG and read the design:
   ```bash
   ./scripts/svg-to-png.sh --single {svg_file}
   ```
   Then read the generated PNG from `XiriGo-Design/Png_Screens/` as visual reference
8. Read existing code in `android/` and `ios/` to understand current patterns
9. Create feature branch (if not already on one): `git checkout -b feature/{pipeline_id} develop`
10. Ensure directories exist: `docs/pipeline/`, `shared/feature-specs/`
11. If issue number known, comment on issue:
    `gh issue comment {N} --body "Pipeline Started -- Agent team spawning..."`

## Create Agent Team

Create an agent team with the following structure. Use **delegate mode**
(Shift+Tab) so you focus purely on coordination, not implementation.

### Git Worktree Isolation (CRITICAL)

All agents that write code MUST run in isolated git worktrees using
`isolation: "worktree"` on the Agent tool. This prevents merge conflicts
when parallel agents commit simultaneously.

**Workflow**:
1. Spawn agent with `isolation: "worktree"` — agent gets its own repo copy + branch
2. Agent commits in its worktree branch
3. When agent finishes, the result includes the worktree branch name
4. Team Lead merges the worktree branch into the feature branch:
   ```bash
   git merge <worktree-branch> --no-edit
   ```
5. Worktree is auto-cleaned if no changes; otherwise branch remains for merge

**Which agents use worktrees**:

| Agent | Worktree? | Reason |
|-------|-----------|--------|
| `architect` | YES | Writes spec files |
| `doc-writer` (ADR) | YES | Writes ADR docs |
| `android-tester` | YES | Writes Android tests (parallel with iOS) |
| `ios-tester` | YES | Writes iOS tests (parallel with Android) |
| `android-dev` | YES | Writes Android code (parallel with iOS) |
| `ios-dev` | YES | Writes iOS code (parallel with Android) |
| `doc-writer` (API) | YES | Writes API docs |
| `reviewer` | YES | May write fix commits |

After EACH agent completes, merge their worktree branch before spawning
dependent agents:
```bash
git merge <worktree-branch> --no-edit
```

### Available Subagents

This project defines specialized subagents in `.claude/agents/`. Each subagent
has its corresponding skill preloaded, the correct model, and appropriate tool
restrictions. Reference these subagent types when spawning teammates:

| Subagent | Model | Preloaded Skill | Memory |
|----------|-------|-----------------|--------|
| `architect` | Opus | architect | project |
| `android-dev` | Opus | android-dev | project |
| `ios-dev` | Opus | ios-dev | project |
| `android-tester` | Opus | test-agent | project |
| `ios-tester` | Opus | test-agent | project |
| `doc-writer` | Sonnet | doc-agent | -- |
| `reviewer` | Opus | review-agent | project |

### Tasks (with dependency chain — SDD + TDD order)

Create these tasks in the shared task list:

| # | Task | Depends On | Subagent Type | Description |
|---|------|------------|---------------|-------------|
| 1 | Design feature spec | -- | `architect` | Platform-agnostic architecture spec |
| 2 | Write ADR | Task 1 | `doc-writer` | Architectural Decision Record |
| 3 | Write Android tests | Task 2 | `android-tester` | TDD: tests FROM spec + ADR (parallel with Task 4) |
| 4 | Write iOS tests | Task 2 | `ios-tester` | TDD: tests FROM spec + ADR (parallel with Task 3) |
| 5 | Implement Android | Tasks 3 | `android-dev` | Code to pass existing tests (parallel with Task 6) |
| 6 | Implement iOS | Tasks 4 | `ios-dev` | Code to pass existing tests (parallel with Task 5) |
| 7 | Verify builds | Tasks 5, 6 | _(Team Lead)_ | Build + test both platforms |
| 8 | Self-Heal | Task 7 (on failure) | _(Team Lead)_ | Auto-fix failures, max 2 retries |
| 9 | Visual Verify | Task 7 (on success) | _(Team Lead)_ | Screenshot vs design PNG comparison |
| 10 | Regression | Task 9 | _(Team Lead)_ | Run ALL tests, not just feature tests |
| 11 | Cross-platform review | Task 10 | `reviewer` | Quality, consistency, spec compliance |
| 12 | Write API docs | Task 11 | `doc-writer` | Feature docs + CHANGELOG |
| 13 | Quality gate | Task 12 | _(Team Lead)_ | Final verification + PR |

### Teammate Spawn Prompts

Spawn teammates with these prompts. **All agents MUST be spawned with
`isolation: "worktree"`** so they work in isolated repo copies.

> **IMPORTANT**: Agents in worktrees commit to their own branch. After each
> agent finishes, the Team Lead merges the worktree branch into the feature
> branch before spawning dependent agents.

---

**Phase 1: Architect** (subagent type: `architect`, isolation: `worktree`)

```
Your task: design a platform-agnostic spec for feature `{feature}`.

Context:
- Feature requirements: see `PROMPTS/BUYER_APP.md` section for {feature}
- API contracts: `shared/api-contracts/`
- Design tokens: `shared/design-tokens/`
- Existing specs: `shared/feature-specs/`
- Design PNG: `XiriGo-Design/Png_Screens/{design_png}` (read this image for visual reference)

Output: `shared/feature-specs/{feature}.md`
Handoff: `docs/pipeline/{feature}-architect.handoff.md`

When done, commit:
git add shared/feature-specs/{feature}.md docs/pipeline/{feature}-architect.handoff.md
git commit -m "docs(specs): add {feature} specification [agent:architect]"
```

---

**Phase 2: ADR-Doc** (subagent type: `doc-writer`, isolation: `worktree`)

```
Write an Architectural Decision Record (ADR) for feature `{feature}`.

Read:
- Architect spec: `shared/feature-specs/{feature}.md`
- Architect handoff: `docs/pipeline/{feature}-architect.handoff.md`
- Existing ADRs in `docs/adr/` for numbering and format

The ADR captures WHY specific architectural choices were made. This document
will be read by testers BEFORE they write tests, so include:
- Architecture decisions and their rationale
- Trade-offs considered
- Component boundaries and responsibilities
- Data flow decisions
- Error handling strategy

Output: `docs/adr/ADR-NNN-{feature}.md`
Handoff: `docs/pipeline/{feature}-adr.handoff.md`

When done, commit:
git add docs/adr/ docs/pipeline/{feature}-adr.handoff.md
git commit -m "docs(adr): add {feature} ADR [agent:doc]"
```

---

**Phase 3: Test-First (TDD)** — spawn BOTH testers in parallel

**Teammate: Android Tester** (subagent type: `android-tester`, isolation: `worktree`)

```
Write tests for feature `{feature}` on Android BEFORE implementation exists.
This is TDD — you define the contract that developers must satisfy.

Read these files carefully:
- Architect spec: `shared/feature-specs/{feature}.md`
- ADR: `docs/adr/ADR-NNN-{feature}.md` (for architectural decisions)
- ADR handoff: `docs/pipeline/{feature}-adr.handoff.md`
- Existing test patterns in `android/app/src/test/`
- Design tokens: `shared/design-tokens/`

Write tests for ALL layers:
- Domain: Use case tests with FakeRepository
- Data: Repository + mapper tests
- Presentation: ViewModel tests with Turbine for Flow testing
- UI: Compose test rules for screen components

Coverage target: >= 80% lines, >= 70% branches.
Tests MUST compile and be runnable (with expected failures since code doesn't exist yet).
Use the Fake pattern: `Fake{Name}Repository` — no mocking frameworks.

Handoff: `docs/pipeline/{feature}-android-test.handoff.md`

When done, commit:
git add android/ docs/pipeline/{feature}-android-test.handoff.md
git commit -m "test({scope}): add {feature} tests (TDD) [agent:android-test] [platform:android]"
```

**Teammate: iOS Tester** (subagent type: `ios-tester`, isolation: `worktree`)

```
Write tests for feature `{feature}` on iOS BEFORE implementation exists.
This is TDD — you define the contract that developers must satisfy.

Read these files carefully:
- Architect spec: `shared/feature-specs/{feature}.md`
- ADR: `docs/adr/ADR-NNN-{feature}.md` (for architectural decisions)
- ADR handoff: `docs/pipeline/{feature}-adr.handoff.md`
- Existing test patterns in `ios/XiriGoEcommerceTests/`
- Design tokens: `shared/design-tokens/`

Write tests for ALL layers:
- Domain: Use case tests with FakeRepository
- Data: Repository + mapper tests
- Presentation: ViewModel tests
- UI: View tests with ViewInspector

Coverage target: >= 80% lines, >= 70% branches.
Tests MUST compile and be runnable (with expected failures since code doesn't exist yet).
Use the Fake pattern: `Fake{Name}Repository` — no mocking frameworks.

Handoff: `docs/pipeline/{feature}-ios-test.handoff.md`

When done, commit:
git add ios/ docs/pipeline/{feature}-ios-test.handoff.md
git commit -m "test({scope}): add {feature} tests (TDD) [agent:ios-test] [platform:ios]"
```

---

**Phase 4: Implementation** — spawn BOTH developers in parallel

**Teammate: Android Dev** (subagent type: `android-dev`, isolation: `worktree`)

```
Implement feature `{feature}` for Android.

Read the architect spec at `shared/feature-specs/{feature}.md`.
Read the ADR at `docs/adr/ADR-NNN-{feature}.md`.
Read ALL existing tests for this feature — your code MUST pass them.
Read the design PNG: `XiriGo-Design/Png_Screens/{design_png}` for visual reference.
Follow Clean Architecture: data/ -> domain/ -> presentation/.

CRITICAL RULES:
- NEVER modify test files — tests are the contract from spec
- Your code must make ALL existing tests pass
- Use only XG* design system components (never raw Material 3)
- All strings must be localized (strings.xml)

Handoff: `docs/pipeline/{feature}-android-dev.handoff.md`

When done, commit:
git add android/ docs/pipeline/{feature}-android-dev.handoff.md
git commit -m "feat({scope}): implement {feature} [agent:android-dev] [platform:android]"
```

**Teammate: iOS Dev** (subagent type: `ios-dev`, isolation: `worktree`)

```
Implement feature `{feature}` for iOS.

Read the architect spec at `shared/feature-specs/{feature}.md`.
Read the ADR at `docs/adr/ADR-NNN-{feature}.md`.
Read ALL existing tests for this feature — your code MUST pass them.
Read the design PNG: `XiriGo-Design/Png_Screens/{design_png}` for visual reference.
Read the Android implementation for consistency (same behavior, platform conventions).
Follow Clean Architecture: Data/ -> Domain/ -> Presentation/.

CRITICAL RULES:
- NEVER modify test files — tests are the contract from spec
- Your code must make ALL existing tests pass
- Use only XG* design system components (never raw SwiftUI)
- All strings must be localized (Localizable.strings)

Handoff: `docs/pipeline/{feature}-ios-dev.handoff.md`

When done, commit:
git add ios/ docs/pipeline/{feature}-ios-dev.handoff.md
git commit -m "feat({scope}): implement {feature} [agent:ios-dev] [platform:ios]"
```

---

**Phase 11: Reviewer** (subagent type: `reviewer`, isolation: `worktree`)

```
Review BOTH Android and iOS implementations of feature `{feature}`.

Check:
- Spec compliance (all screens, states, API calls match spec)
- TDD compliance (tests were NOT modified by developers)
- Code quality (no Any/!, explicit types, Clean Architecture)
- Cross-platform consistency (same behavior on both)
- Test coverage (>= 80%)
- Security (no secrets in logs, auth handling)
- XG* component usage (no raw Material 3 / SwiftUI in feature screens)
- Localization (no hardcoded strings)

If issues found: message the relevant teammate directly with specific fixes.

Handoff: `docs/pipeline/{feature}-review.handoff.md`

When done, commit:
git add docs/pipeline/{feature}-review.handoff.md
git commit -m "chore({scope}): review approved for {feature} [agent:review]"
```

---

**Phase 12: API-Doc** (subagent type: `doc-writer`, isolation: `worktree`)

```
Document feature `{feature}` after implementation and review are complete.

Read ALL handoff files and source code for this feature.

Create:
1. Feature README: `docs/features/{feature}.md`
2. API integration doc: `docs/api/{feature}.md` (endpoints used, auth, error codes)
3. CHANGELOG entry under [Unreleased]

Handoff: `docs/pipeline/{feature}-doc.handoff.md`

When done, commit:
git add docs/ CHANGELOG.md
git commit -m "docs({scope}): add {feature} documentation [agent:doc]"
```

## Your Responsibilities as Team Lead

1. **Delegate mode**: Enable it. You do NOT write code — only coordinate.
2. **Git operations**: YOU create the feature branch, final push, and PR.
   Teammates work in worktrees — YOU merge their branches back.
3. **Worktree merge workflow**: After EACH agent completes:
   ```bash
   git merge <worktree-branch> --no-edit
   ```
   Merge order: architect -> ADR -> testers -> devs -> reviewer -> doc
   For parallel agents (android ‖ ios), merge one then the other —
   they modify different directories so conflicts are unlikely.
4. **GitHub issue tracking**: If `--issue N` was provided, comment on the issue
   after each pipeline stage completes:
   ```bash
   gh issue comment {N} --body "{stage} completed by {agent}"
   ```

### Phase 7: Verify Builds (YOU do this)

After both developers finish and branches are merged, run verification:
```bash
# Android
cd android && ./gradlew ktlintCheck && ./gradlew detekt && ./gradlew test && cd ..

# iOS
cd ios
xcodebuild test \
  -scheme XiriGoEcommerce \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult \
  CODE_SIGNING_ALLOWED=NO
cd ..
```

If verification fails, proceed to Self-Heal (Phase 8).
If verification passes, proceed to Visual Verify (Phase 9).

### Phase 8: Self-Heal (YOU do this, on failure only)

If build/test verification fails:
1. Read the error output carefully
2. Identify which platform failed (Android, iOS, or both)
3. Spawn the relevant developer agent again with the error context:
   ```
   Fix the following build/test failures for feature `{feature}`:

   {paste error output}

   CRITICAL: Do NOT modify any test files. Fix only implementation code.
   ```
4. After fix, re-run verification
5. Maximum 2 retry rounds. If still failing after 2 retries, STOP and report to user.

### Phase 9: Visual Verify (YOU do this, on success)

Compare the implementation with the design PNG:
1. Run the app on simulator/emulator and take a screenshot:
   ```bash
   # iOS — use ios-simulator MCP or:
   xcrun simctl io booted screenshot /tmp/xirigo-screenshot-ios.png

   # Android — use ADB:
   adb exec-out screencap -p > /tmp/xirigo-screenshot-android.png
   ```
2. Read the design PNG: `XiriGo-Design/Png_Screens/{design_png}`
3. Read the screenshot(s): `/tmp/xirigo-screenshot-*.png`
4. Compare visually — check:
   - Layout structure matches design
   - Colors match design tokens
   - Typography matches design tokens
   - Spacing and alignment are correct
   - Icons and images are in correct positions
5. If significant visual differences found, send fix instructions to the relevant developer.
   Max 1 visual fix round.

### Phase 10: Regression (YOU do this)

Run ALL tests across the entire project, not just the new feature:
```bash
# Android — all tests
cd android && ./gradlew test && cd ..

# iOS — all tests
cd ios
xcodebuild test \
  -scheme XiriGoEcommerce \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
cd ..
```

If regression failures found in OTHER features, investigate and fix before proceeding.

### Phase 13: Quality Gate + PR (YOU do this)

After all phases complete:
1. Final verification (build + lint + test + coverage)
2. Verify all handoff files exist
3. Push and create PR:
   ```bash
   git push -u origin feature/{pipeline_id}
   gh pr create --base develop \
     --title "feat({scope}): {feature}" \
     --body "## Summary
   - Platform-agnostic spec designed (Architect)
   - ADR documented (ADR-Doc)
   - Tests written first from spec (TDD)
   - Android: Kotlin + Compose implementation
   - iOS: Swift + SwiftUI implementation
   - Self-heal applied (if needed)
   - Visual verification passed
   - Regression tests passed
   - Cross-platform review passed
   - API documentation written
   - Quality gate verified (build + lint + test)

   Closes #{issue_number}

   ## Pipeline Status
   | Phase | Task | Agent | Status |
   |-------|------|-------|--------|
   | 1 | Architect | architect | done |
   | 2 | ADR-Doc | doc-writer | done |
   | 3 | Android Tests (TDD) | android-tester | done |
   | 3 | iOS Tests (TDD) | ios-tester | done |
   | 4 | Android Dev | android-dev | done |
   | 4 | iOS Dev | ios-dev | done |
   | 7 | Verify | team-lead | done |
   | 8 | Self-Heal | team-lead | {skipped or done} |
   | 9 | Visual Verify | team-lead | done |
   | 10 | Regression | team-lead | done |
   | 11 | Review | reviewer | done |
   | 12 | API-Doc | doc-writer | done |
   | 13 | Quality Gate | team-lead | done |

   Generated by AI Agent Pipeline" \
     --label "agent:pipeline"

   # Enable auto-merge
   gh pr merge --auto --squash
   ```
4. Clean up:
   ```bash
   git worktree prune
   rm -rf .claude/worktrees/ 2>/dev/null
   git branch | grep 'worktree-' | xargs -r git branch -D 2>/dev/null
   ```

## Rules

1. YOU handle all git branch/push/PR operations — teammates only commit in worktrees
2. ALL code-writing agents MUST use `isolation: "worktree"` — no exceptions
3. **TDD is non-negotiable**: Tests are written BEFORE implementation
4. **Developers NEVER modify test files** — tests are the contract from spec
5. Android Tester and iOS Tester MUST run in parallel (both depend on ADR)
6. Android Dev and iOS Dev MUST run in parallel (both depend on their respective tests)
7. Reviewer can message teammates directly for fixes
8. On failure after 2 retries: STOP and report to user
9. Always instruct teammates to read CLAUDE.md first
10. Subagent definitions provide base config — your spawn prompts add feature context
11. PR body MUST include `Closes #{issue_number}` to auto-close the GitHub issue
12. Quality gate (Task 13) is mandatory — never skip lint or test checks
13. After each worktree agent finishes, merge their branch before spawning dependents
14. Visual verification requires `--svg` argument or a known design PNG
15. ADR must be written BEFORE tests — testers need architectural context
