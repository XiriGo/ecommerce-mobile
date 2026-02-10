---
name: create-pr
description: "Push current branch and create a Pull Request targeting develop"
allowed-tools: Bash, Read, Grep, Glob
argument-hint: "[base-branch (default: develop)]"
---

# Create PR

Push the current branch and create a Pull Request.

## Arguments
`$ARGUMENTS` — optional base branch (default: `develop`)

## Process

1. **Gather Context**
   - `git branch --show-current` — get current branch name
   - `git log develop..HEAD --oneline` — commits in this branch
   - `git diff develop --stat` — changed files summary

2. **Read Handoffs**
   - Check `docs/pipeline/` for relevant handoff files
   - Extract review status (if review agent ran)

3. **Push**
   - `git push -u origin {current-branch}`

4. **Create PR**
```bash
gh pr create --base {base-branch} --title "{type}({scope}): {description}" --body "## Summary
- {bullet points from commits}

## Changes
### Android
- {android changes}

### iOS
- {ios changes}

## Pipeline Status
| Phase | Agent | Status |
|-------|-------|--------|
| Architect | architect | ✓ |
| Android Dev | android-dev | ✓ |
| iOS Dev | ios-dev | ✓ |
| Test | test-agent | ✓ |
| Doc | doc-agent | ✓ |
| Review | review-agent | ✓ |
"
```

5. **Report** PR URL
