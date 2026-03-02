# Architect Handoff: HomeScreenSkeleton (DQ-36)

## Feature Spec
- `shared/feature-specs/home-screen-skeleton.md`

## Architecture Decisions
- HomeScreenSkeleton is a **feature-level component**, not a design system atom
- Lives in `feature/home/presentation/component/` on both platforms
- Composes existing design system primitives: SkeletonBox, SkeletonLine, SkeletonCircle, ProductCardSkeleton
- Replaces generic `XGLoadingView()` in HomeScreen loading state
- No new tokens needed — reuses existing spacing, corner radius, and skeleton tokens

## Layout
Mirrors real HomeScreen sections:
1. Search bar skeleton (pill-shaped SkeletonBox)
2. Hero banner skeleton (full-width SkeletonBox)
3. Categories skeleton (circles + labels in horizontal row)
4. Popular products skeleton (horizontal ProductCardSkeleton row)
5. New arrivals skeleton (2-column ProductCardSkeleton grid)

## Integration
Replace `XGLoadingView()` with `HomeScreenSkeleton()` in the `.loading` state branch.
