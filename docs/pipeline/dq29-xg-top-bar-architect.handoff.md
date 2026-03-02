# DQ-29 XGTopBar — Architect Handoff

## Summary
Token audit spec created for XGTopBar. Both platforms need variant support (transparent + surface) and direct token usage.

## Key Changes Required
- Add `XGTopBarVariant` enum (surface / transparent)
- Android: replace MaterialTheme delegates with XGColors/XGTypography tokens
- iOS: fix height from 48pt to 56pt, add variant support
- Both: explicit 56dp/pt height, 24dp/pt icon size

## Token Spec
See `shared/feature-specs/xg-top-bar.md` for full resolved token table.
