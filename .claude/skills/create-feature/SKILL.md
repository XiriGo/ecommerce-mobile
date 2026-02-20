---
name: create-feature
description: "Create a new GitHub Issue with FAANG-standard template, labels, milestone, and project board placement"
argument-hint: "<M#-NN> <title> [--deps #N,#M] [--priority p0|p1|p2] [--platform android|ios|both]"
---

# Create Feature — GitHub Issue Factory

You create a **single new feature issue** on GitHub with the full FAANG-standard
template, proper labels, milestone assignment, project board placement, and
dependency linking. The result is identical to the issues created by the
bulk migration — same traceability, same structure.

## Arguments

Parse: `$ARGUMENTS`

| Argument | Required | Default | Example |
|----------|----------|---------|---------|
| Feature ID | Yes | — | `M1-09`, `M2-08`, `M4-06` |
| Title | Yes | — | `Product Comparison` |
| `--deps` | No | none | `--deps #12,#13` or `--deps M1-06,M1-07` |
| `--priority` | No | `p2` | `--priority p0` |
| `--platform` | No | `both` | `--platform android` |
| `--type` | No | `feature` | `--type infra` or `--type fix` |
| `--description` | No | auto | `--description "Compare products side by side"` |

Feature ID format: `M<phase>-<number>` (e.g., `M1-09`, `M2-08`).
The phase number determines the milestone automatically.

## Pre-flight

1. Read `CLAUDE.md` for project standards
2. Read `scripts/issue-map.json` for existing feature ID → issue number mapping
3. Read `PROMPTS/BUYER_APP.md` to find requirements for this feature (if exists)
4. Read `shared/api-contracts/` to find relevant API endpoints
5. Verify `gh` CLI is authenticated: `gh auth status`
6. Verify the feature ID doesn't already exist in `issue-map.json`

## Issue Body Template

Build the issue body using this template. Fill in as much detail as possible
from `PROMPTS/BUYER_APP.md` and `shared/api-contracts/`. If the feature isn't
in the requirements doc, ask the user for details or use the provided `--description`.

```markdown
## Overview
{description — from PROMPTS/BUYER_APP.md or --description argument}

## Requirements
### Functional
- [ ] {requirement 1}
- [ ] {requirement 2}
- [ ] {requirement N}

### Non-Functional
- [ ] Loading, success, error, empty states handled
- [ ] Offline: graceful degradation
- [ ] Min 60fps scroll performance
- [ ] Accessibility: all interactive elements have labels
- [ ] All strings localized (en, mt, tr)

## API Endpoints
| Method | Path | Purpose |
|--------|------|---------|
| {GET/POST/...} | {/store/...} | {description} |

_(from shared/api-contracts/)_

## Acceptance Criteria
- [ ] Architect spec completed (`shared/feature-specs/{name}.md`)
- [ ] Android implementation completed
- [ ] iOS implementation completed
- [ ] Unit test coverage >= 80%
- [ ] All lint checks pass (ktlint + detekt + SwiftLint)
- [ ] Architecture tests pass
- [ ] Cross-platform consistency verified
- [ ] Documentation written

## Pipeline Checklist
- [ ] Architect: Feature spec
- [ ] Android Dev: Kotlin + Compose
- [ ] iOS Dev: Swift + SwiftUI
- [ ] Android Tester: JUnit + MockK
- [ ] iOS Tester: Swift Testing
- [ ] Doc Writer: Feature docs + CHANGELOG
- [ ] Reviewer: Cross-platform review
- [ ] Quality Gate: Build + Lint + Test

## Technical Details
| Field | Value |
|-------|-------|
| Feature ID | `{feature_id}` |
| Pipeline ID | `{pipeline_id}` |
| Spec | `shared/feature-specs/{name}.md` |
| API Contract | `shared/api-contracts/{relevant}.json` |
| Branch | `feature/{pipeline_id}` |
| Android Path | `android/app/src/main/java/com/molt/marketplace/feature/{name}/` |
| iOS Path | `ios/MoltMarketplace/Feature/{Name}/` |

## Dependencies
{Depends on #N — one per line, or "None" if no dependencies}
```

## Label Assignment

Determine labels from arguments and feature ID:

```bash
# Always applied
LABELS="agent:pipeline"

# Type (from --type, default: feature)
LABELS="$LABELS,type:{type}"

# Platform (from --platform, default: both)
LABELS="$LABELS,platform:{platform}"

# Phase (extracted from feature ID: M0→phase:m0, M1→phase:m1, etc.)
LABELS="$LABELS,phase:m{N}"

# Priority (from --priority, default: p2)
LABELS="$LABELS,priority:{priority}"

# Status (determined by dependencies)
# If ALL dependency issues are closed → status:ready
# If ANY dependency issue is open → status:blocked
# If no dependencies → status:ready
LABELS="$LABELS,status:{ready|blocked}"
```

## Milestone Assignment

Map phase from feature ID to milestone title:

| Phase | Milestone Title |
|-------|----------------|
| M0 | `M0: Foundation` |
| M1 | `M1: Core Features` |
| M2 | `M2: Commerce` |
| M3 | `M3: User Features` |
| M4 | `M4: Enhancements` |

## Execution Steps

### Step 1: Validate Inputs

```bash
# Check feature ID format
echo "{feature_id}" | grep -qE '^M[0-4]-[0-9]{2}$'

# Check not already in issue-map.json
jq -r '."{feature_id}" // empty' scripts/issue-map.json
```

If feature ID already exists, STOP and report: "Feature {id} already exists as issue #{N}."

### Step 2: Gather Requirements

1. Search `PROMPTS/BUYER_APP.md` for the feature name/title
2. Search `shared/api-contracts/*.json` for relevant endpoints
3. If `--description` not provided and feature not found in docs, ask user for a brief description

### Step 3: Resolve Dependencies

For each dependency in `--deps`:
- If format is `#N` → use directly as GitHub issue reference
- If format is `M1-06` → look up in `scripts/issue-map.json` to get `#N`
- Check each dependency issue state: `gh issue view {N} --json state -q '.state'`
- If ALL dependencies are `CLOSED` → status is `ready`
- If ANY dependency is `OPEN` → status is `blocked`

### Step 4: Create Issue

```bash
gh issue create \
  --title "[{feature_id}] {title}" \
  --body "{body}" \
  --milestone "{milestone_title}" \
  --label "{labels}"
```

Capture the new issue number from the output URL.

### Step 5: Add to Project Board

```bash
# Get project number (Molt Mobile Roadmap)
PROJECT_NUM=$(gh project list --format json | jq -r '.projects[] | select(.title == "Molt Mobile Roadmap") | .number')

# Add issue to project
gh project item-add $PROJECT_NUM --owner {owner} --url {issue_url}
```

Set the Status field based on dependency resolution:
- No dependencies or all closed → `Ready`
- Has open dependencies → `Backlog`

### Step 6: Update Issue Map

Read `scripts/issue-map.json`, add the new entry, write back:

```bash
# Add new mapping
jq --arg id "{feature_id}" --argjson num {issue_number} '. + {($id): $num}' scripts/issue-map.json > tmp.json
mv tmp.json scripts/issue-map.json
```

Commit the update:
```bash
git add scripts/issue-map.json
git commit -m "chore: add {feature_id} to issue map (#{issue_number})"
```

### Step 7: Report

Output a summary:

```
Feature Created Successfully
============================
Issue:      #{number} — [{feature_id}] {title}
URL:        https://github.com/{owner}/{repo}/issues/{number}
Milestone:  {milestone}
Labels:     {labels}
Status:     {ready|blocked}
Dependencies: {#N, #M | None}
Branch:     feature/{pipeline_id}
Pipeline:   /pipeline-run {pipeline_id} --issue {number}
============================
```

## Examples

```bash
# Simple feature, no dependencies
/create-feature M1-09 "Product Comparison"

# Feature with dependencies on existing issues
/create-feature M2-08 "Order Tracking" --deps M2-05,M3-01 --priority p1

# Infrastructure task, single platform
/create-feature M0-07 "Push Notification Setup" --type infra --platform both --priority p0

# Feature with explicit description
/create-feature M4-06 "Dark Mode" --description "Toggle dark/light theme from settings"

# Fix, referencing issue numbers directly
/create-feature M1-10 "Login Error Handling Fix" --type fix --deps #8 --platform both
```

## Rules

1. **Feature ID must be unique** — never create duplicate IDs
2. **Template is mandatory** — every issue uses the full template, no shortcuts
3. **Labels are mandatory** — type + platform + phase + priority + status
4. **Milestone is mandatory** — always assigned based on phase
5. **Project board placement is mandatory** — always added to "Molt Mobile Roadmap"
6. **Issue map must be updated** — `scripts/issue-map.json` is the source of truth for ID→number mapping
7. **Dependencies are verified** — check actual issue state, not assumptions
8. **Same traceability** — issue created here is indistinguishable from migration-created issues
