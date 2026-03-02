# Architect Handoff — XGErrorView Crossfade (DQ-27)

## Status: COMPLETE

## Spec Location
`shared/feature-specs/xg-error-view.md`

## Key Decisions

1. **Backward compatible**: Keep existing `XGErrorView(message:, onRetry:)` signature. Add new overload with `isError` + `content` for crossfade.
2. **Follow XGLoadingView pattern**: Both platforms use the exact same crossfade approach as XGLoadingView (AnimatedContent on Android, Group+animation on iOS).
3. **Token-driven animation**: Duration from `XGMotion.Crossfade.contentSwitch` (200ms).
4. **No new files**: Only modify existing XGErrorView source + test files.

## For Android Dev
- Add `AnimatedContent` overload with `isError: Boolean` and `content: @Composable () -> Unit`
- Use `fadeIn(tween(XGMotion.Crossfade.CONTENT_SWITCH)) togetherWith fadeOut(tween(...))`
- Keep the static overload as-is

## For iOS Dev
- Convert `XGErrorView` to generic `XGErrorView<Content: View>` with `isError: Bool` and `@ViewBuilder content`
- Add convenience `where Content == EmptyView` extension for backward compatibility
- Use `.animation(.easeInOut(duration: XGMotion.Crossfade.contentSwitch), value: isError)` + `.transition(.opacity)`
