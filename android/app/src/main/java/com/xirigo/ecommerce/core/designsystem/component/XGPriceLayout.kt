package com.xirigo.ecommerce.core.designsystem.component

/** Controls the arrangement of sale price and strikethrough in [XGPriceText]. */
enum class XGPriceLayout {
    /** Sale price + strikethrough side-by-side (Row). Default for standard/grid cards. */
    Inline,

    /** Strikethrough above, sale price below (Column). Used for featured/horizontal-scroll cards. */
    Stacked,
}
