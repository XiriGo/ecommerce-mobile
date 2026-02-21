# Handoff: di-setup -- Doc Writer

## Feature
**M0-05: DI Setup** -- Hilt modules (Android) + Factory container registrations (iOS) for network, storage, coroutine, and common infrastructure dependencies.

## Status
COMPLETE -- Feature README written, CHANGELOG updated.

## Artifacts

| Artifact | Path | Action |
|----------|------|--------|
| Feature README | `docs/features/di-setup.md` | CREATED |
| CHANGELOG | `CHANGELOG.md` | MODIFIED (entry added under `[Unreleased] → Added → M0-05: DI Setup`) |
| This Handoff | `docs/pipeline/di-setup-doc.handoff.md` | CREATED |

---

## Sources Read

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project standards and file location conventions |
| `shared/feature-specs/di-setup.md` | Canonical spec: qualifier annotations, DI graph, Room shell, feature DI pattern, test patterns |
| `docs/pipeline/di-setup-architect.handoff.md` | Gap analysis: what M0-03 already built vs. what M0-05 adds; Android/iOS task split |
| `docs/pipeline/di-setup-android-dev.handoff.md` | Android implementation: files created/modified, key design decisions (PlaceholderEntity, unauthenticated client, fallbackToDestructiveMigration) |
| `docs/pipeline/di-setup-ios-dev.handoff.md` | iOS implementation: existing registrations verified, feature DI pattern documented in Container+Extensions.swift |
| `docs/pipeline/di-setup-android-test.handoff.md` | Android test results: 55 tests across 4 files; Robolectric for Storage |
| `docs/pipeline/di-setup-ios-test.handoff.md` | iOS test results: 21 tests across 2 files (14 ContainerTests + 7 NetworkMonitorTests) |
| `docs/features/navigation.md` | Reference for feature README structure and format |
| `CHANGELOG.md` | Existing entries for insertion point |

---

## Documentation Decisions

1. **Spec vs. reality**: The architect handoff identified that M0-03 pre-built significant DI infrastructure (NetworkModule, NetworkMonitor, APIClient, TokenProvider). The feature doc reflects the actual implementation — what M0-05 added vs. what was inherited from M0-03.

2. **iOS simplification**: The spec originally called for `authenticatedSession`/`unauthenticatedSession` container registrations and a protocol/impl split for `APIClient` and `NetworkMonitor`. The architect confirmed none of these were needed because M0-03's concrete class approach is correct. The doc reflects this accurately.

3. **Canonical pattern emphasis**: The feature DI pattern section is the primary deliverable for future feature developers. It is written as a copy-paste-and-rename guide with inline commentary on rules (why use cases don't need modules, why repositories are ViewModel-scoped, why init-based injection is preferred on iOS).

4. **PlaceholderEntity**: Documented clearly so future developers know to remove it when adding the first real Room entity (M2-01 Cart).

5. **Test count accuracy**: Counts taken directly from tester handoffs — 55 Android (QualifiersTest 11, CoroutineModuleTest 10, NetworkModuleTest 25, StorageModuleTest 9) and 21 iOS (ContainerTests 14, NetworkMonitorTests 7).

---

## For Reviewer

The feature README covers:
- Overview and dependency graph (what blocks this, what this blocks)
- DI scoping rules table (Singleton / ViewModel / Transient) with rationale
- Qualifier annotation table (Android)
- Singleton dependency graph for both platforms
- Room database shell and entity evolution pattern
- Canonical feature DI pattern for M1+ (mandatory) — both platforms with code examples
- Test replacement patterns (both platforms)
- File structure for both platforms (with actual file paths)
- NetworkMonitor implementation notes
- Testing summary with per-file breakdown
- Integration points for downstream features

CHANGELOG entry format matches existing M0-03 and M0-04 entries (feature bullet + tests bullet with per-file breakdown).

---

**Completed**: 2026-02-21
**Agent**: doc-writer
