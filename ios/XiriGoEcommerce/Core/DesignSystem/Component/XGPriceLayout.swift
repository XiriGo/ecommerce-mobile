/// Controls the arrangement of sale price and strikethrough in ``XGPriceText``.
///
/// Token source: `components/atoms/xg-price-text.json`.
enum XGPriceLayout {
    /// Sale price + strikethrough side-by-side (HStack). Default for standard/grid cards.
    case inline
    /// Strikethrough above, sale price below (VStack). Used for featured/horizontal-scroll cards.
    case stacked
}
