# Architect Agent Memory

## Spec Format Pattern
- Follow the structure in `shared/feature-specs/app-onboarding.md` as the canonical template
- Sections: Overview, API Mapping, Data Models, Architecture, New Design System Components, Existing Component Updates, Screen Layout, Screen States, Navigation, Localization, Accessibility, File Manifest, Platform-Specific Notes, Verification Criteria
- Always provide both Android (Kotlin) and iOS (Swift) pseudocode for models, repos, use cases, VMs
- Use plaintext pseudocode blocks (not language-tagged) for cross-platform consistency

## Handoff Format Pattern
- Follow `docs/pipeline/app-onboarding-architect.handoff.md` as template
- Include: Feature summary, Status, Artifacts table, Spec summary, Key decisions, Downstream dependencies, Verification pointer, Notes for next features

## Key Conventions
- Android DI: Hilt (@HiltViewModel, @Inject, @Module @InstallIn)
- iOS DI: Factory container extensions (Container+Feature.swift)
- iOS ViewModel: @MainActor @Observable final class
- Android ViewModel: @HiltViewModel with StateFlow
- iOS use cases: struct conforming to Sendable, method named `execute()`
- Android use cases: class with `operator fun invoke()`
- Domain models: data class (Kotlin) / struct (Swift) conforming to Identifiable, Equatable, Sendable

## Existing Components (verified Feb 2026)
- XGPaginationDots: exists on both platforms (from onboarding)
- XGProductCard: exists in XGCard.kt/XGCard.swift, has wishlist params already
- XGImage, XGPriceText, XGRatingBar, XGBadge, XGButton, XGTextField, XGChip, XGLoadingView, XGErrorView, XGEmptyView: all exist
- XGBrandGradient, XGBrandPattern, XGLogoMark: exist from onboarding

## Design Token Files
- Colors: `shared/design-tokens/colors.json`
- Typography: `shared/design-tokens/typography.json`
- Spacing: `shared/design-tokens/spacing.json`
- Gradients: `shared/design-tokens/gradients.json`
- Components: `shared/design-tokens/components.json`
