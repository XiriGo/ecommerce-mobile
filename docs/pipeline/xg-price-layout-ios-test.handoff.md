# iOS Test Handoff: XGPriceLayout (DQ-38)

## Summary

Added `XGPriceLayoutTests` suite to `XGPriceTextTests.swift` covering
the extracted `XGPriceLayout` enum.

## Tests Added

| Test | Description |
|------|-------------|
| `layouts_allCasesExist` | Verifies both `.inline` and `.stacked` cases exist |
| `inline_isDefaultCase` | Confirms `.inline` resolves correctly |
| `stacked_isDistinctFromInline` | Ensures `.stacked` differs from `.inline` |
| `priceText_inlineLayout_initialises` | XGPriceText init with `.inline` layout |
| `priceText_stackedLayout_initialises` | XGPriceText init with `.stacked` layout and sale price |
| `priceText_defaultLayout_isInline` | XGPriceText defaults to `.inline` when layout omitted |

## Coverage

- All enum cases covered
- Integration with XGPriceText verified for both layouts
- Default parameter behavior validated

## Next Agent

Doc Writer -> document the feature
