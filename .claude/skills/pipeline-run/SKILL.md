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
- `--issue N`: GitHub issue number to link (for progress tracking)
- Remaining arguments: brief description (optional)

## Pre-flight (YOU do this before spawning anyone)

1. Read `CLAUDE.md` for project overview (lean — no platform-specific details)
2. Read `scripts/issue-map.json` — find the feature's GitHub issue number
3. If `--issue N` provided, read the issue body for requirements:
   `gh issue view N --json body,title`
4. Read `PROMPTS/BUYER_APP.md` — find the relevant feature requirements section
5. Read `shared/api-contracts/` for relevant API contracts
6. Read `shared/design-tokens/` for design tokens
7. Read existing code in `android/` and `ios/` to understand current patterns
8. Create feature branch (if not already on one): `git checkout -b feature/{pipeline_id} develop`
9. Ensure directories exist: `docs/pipeline/`, `shared/feature-specs/`
10. If issue number known, comment on issue:
    `gh issue comment {N} --body "🚀 **Pipeline Started** — Agent team spawning..."`

## Create Agent Team

Create an agent team with the following structure. Use **delegate mode**
(Shift+Tab) so you focus purely on coordination, not implementation.

### Git Worktree Isolation (CRITICAL)

All agents that write code MUST run in isolated git worktrees using
`isolation: "worktree"` on the Agent tool. This prevents merge conflicts
when parallel agents (Android Dev ‖ iOS Dev, Android Tester ‖ iOS Tester)
commit simultaneously.

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
| `android-dev` | YES | Writes Android code (parallel with iOS) |
| `ios-dev` | YES | Writes iOS code (parallel with Android) |
| `android-tester` | YES | Writes Android tests (parallel with iOS) |
| `ios-tester` | YES | Writes iOS tests (parallel with Android) |
| `doc-writer` | YES | Writes docs |
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
| `android-tester` | Sonnet | test-agent | project |
| `ios-tester` | Sonnet | test-agent | project |
| `doc-writer` | Sonnet | doc-agent | — |
| `reviewer` | Opus | review-agent | project |

### Tasks (with dependency chain)

Create these tasks in the shared task list:

| # | Task | Depends On | Subagent Type | Description |
|---|------|------------|---------------|-------------|
| 1 | Design feature spec | — | `architect` | Platform-agnostic architecture spec |
| 2 | Implement Android | Task 1 | `android-dev` | Kotlin + Jetpack Compose + Material 3 |
| 3 | Implement iOS | Task 1 | `ios-dev` | Swift + SwiftUI (parallel with Task 2) |
| 4 | Test Android | Task 2 | `android-tester` | JUnit 4 + MockK + Turbine + Compose Test |
| 5 | Test iOS | Task 3 | `ios-tester` | Swift Testing + ViewInspector (parallel with Task 4) |
| 6 | Document feature | Tasks 4, 5 | `doc-writer` | Feature docs + CHANGELOG |
| 7 | Cross-platform review | Task 6 | `reviewer` | Quality, consistency, spec compliance |
| 8 | Quality gate | Task 7 | _(Team Lead)_ | Build + lint + test verification |

### Teammate Spawn Prompts

Spawn teammates with these prompts. **All agents MUST be spawned with
`isolation: "worktree"`** so they work in isolated repo copies.

The subagent definitions in `.claude/agents/` provide the base configuration
(model, tools, skills, memory). Your spawn prompt adds the feature-specific
context. Replace `{feature}` and `{scope}` with actual values.

> **IMPORTANT**: Agents in worktrees commit to their own branch. After each
> agent finishes, the Team Lead merges the worktree branch into the feature
> branch before spawning dependent agents.

---

**Teammate: Architect** (subagent type: `architect`, isolation: `worktree`)

```
Your task: design a platform-agnostic spec for feature `{feature}`.

Context:
- Feature requirements: see `PROMPTS/BUYER_APP.md` section for {feature}
- API contracts: `shared/api-contracts/`
- Design tokens: `shared/design-tokens/`
- Existing specs: `shared/feature-specs/`

Output: `shared/feature-specs/{feature}.md`
Handoff: `docs/pipeline/{feature}-architect.handoff.md`

When done, commit:
git add shared/feature-specs/{feature}.md docs/pipeline/{feature}-architect.handoff.md
git commit -m "docs(specs): add {feature} specification [agent:architect]"
```

---

**Teammate: Android Dev** (subagent type: `android-dev`, isolation: `worktree`)

```
Implement feature `{feature}` for Android.

Read the architect spec at `shared/feature-specs/{feature}.md`.
Follow Clean Architecture: data/ → domain/ → presentation/.

Handoff: `docs/pipeline/{feature}-android-dev.handoff.md`

When done, commit:
git add android/ docs/pipeline/{feature}-android-dev.handoff.md
git commit -m "feat({scope}): implement {feature} [agent:android-dev] [platform:android]"
```

---

**Teammate: iOS Dev** (subagent type: `ios-dev`, isolation: `worktree`)

```
Implement feature `{feature}` for iOS.

Read the architect spec at `shared/feature-specs/{feature}.md`.
Read the Android implementation for consistency (same behavior, platform conventions).
Follow Clean Architecture: Data/ → Domain/ → Presentation/.

Handoff: `docs/pipeline/{feature}-ios-dev.handoff.md`

When done, commit:
git add ios/ docs/pipeline/{feature}-ios-dev.handoff.md
git commit -m "feat({scope}): implement {feature} [agent:ios-dev] [platform:ios]"
```

---

**Teammate: Android Tester** (subagent type: `android-tester`, isolation: `worktree`)

```
Write tests for feature `{feature}` on Android.

Read all Android source files for this feature.
Coverage target: >= 80% lines, >= 70% branches.

Handoff: `docs/pipeline/{feature}-android-test.handoff.md`

When done, commit:
git add android/ docs/pipeline/{feature}-android-test.handoff.md
git commit -m "test({scope}): add {feature} tests [agent:android-test] [platform:android]"
```

---

**Teammate: iOS Tester** (subagent type: `ios-tester`, isolation: `worktree`)

```
Write tests for feature `{feature}` on iOS.

Read all iOS source files for this feature.
Coverage target: >= 80% lines, >= 70% branches.

Handoff: `docs/pipeline/{feature}-ios-test.handoff.md`

When done, commit:
git add ios/ docs/pipeline/{feature}-ios-test.handoff.md
git commit -m "test({scope}): add {feature} tests [agent:ios-test] [platform:ios]"
```

---

**Teammate: Doc Writer** (subagent type: `doc-writer`, isolation: `worktree`)

```
Document feature `{feature}`.

Read ALL handoff files and source code for this feature.

Create:
1. Feature README: `docs/features/{feature}.md`
2. CHANGELOG entry under [Unreleased]

Handoff: `docs/pipeline/{feature}-doc.handoff.md`

When done, commit:
git add docs/ CHANGELOG.md
git commit -m "docs({scope}): add {feature} documentation [agent:doc]"
```

---

**Teammate: Reviewer** (subagent type: `reviewer`, isolation: `worktree`)

```
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
   Teammates work in worktrees — YOU merge their branches back.
3. **Worktree merge workflow**: After EACH agent completes:
   ```bash
   # Agent result includes worktree branch name, e.g. "worktree/architect-abc123"
   git merge <worktree-branch> --no-edit
   ```
   Always merge sequentially: architect first, then devs, then testers, etc.
   For parallel agents (android-dev ‖ ios-dev), merge one then the other —
   they modify different directories so conflicts are unlikely.
4. **GitHub issue tracking**: If `--issue N` was provided, comment on the issue
   after each pipeline stage completes:
   ```bash
   gh issue comment {N} --body "✅ **{stage}** completed by {agent}"
   ```
5. **Verification gates**: After teammates finish and branches are merged,
   verify files exist on the feature branch.
6. **Quality gate (Task 8)**: After reviewer approves, run verification yourself:
   ```bash
   cd android && ./gradlew ktlintCheck && ./gradlew detekt && ./gradlew test && cd ..
   ```
   If any check fails, send the failure back to the relevant developer teammate.
   Max 2 fix rounds before escalating to user.
7. **Review feedback loop**: If reviewer requests changes, the reviewer
   messages the relevant developer teammate directly. Wait for the fix
   and re-review (max 2 rounds).
8. **After ALL tasks complete**:
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
   - Quality gate verified (build + lint + test)

   Closes #{issue_number}

   ## Pipeline Status
   | Task | Subagent | Status |
   |------|----------|--------|
   | Architect | architect | ✅ |
   | Android Dev | android-dev | ✅ |
   | iOS Dev | ios-dev | ✅ |
   | Android Test | android-tester | ✅ |
   | iOS Test | ios-tester | ✅ |
   | Doc | doc-writer | ✅ |
   | Review | reviewer | ✅ |
   | Quality Gate | verify | ✅ |

   🤖 Generated by AI Agent Pipeline" \
     --label "agent:pipeline"

   # Enable auto-merge
   gh pr merge --auto --squash
   ```
9. **Clean up the team** after PR is created.
10. **Clean stale worktrees** after team shutdown — agents leave orphaned worktrees:
    ```bash
    git worktree prune
    rm -rf .claude/worktrees/ 2>/dev/null
    git branch | grep 'worktree-' | xargs -r git branch -D 2>/dev/null
    ```

## Rules

1. YOU handle all git branch/push/PR operations — teammates only commit in worktrees
2. ALL code-writing agents MUST use `isolation: "worktree"` — no exceptions
3. Android Dev and iOS Dev MUST run in parallel (both depend on Architect only)
4. Android Tester and iOS Tester MUST run in parallel
5. Reviewer can message teammates directly for fixes
6. On failure after 2 retries: STOP and report to user
7. Always instruct teammates to read CLAUDE.md first
8. Subagent definitions provide base config — your spawn prompts add feature context
9. PR body MUST include `Closes #{issue_number}` to auto-close the GitHub issue
10. Quality gate (Task 8) is mandatory — never skip lint or test checks
11. After each worktree agent finishes, merge their branch before spawning dependents
