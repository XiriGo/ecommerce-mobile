import Testing
@testable import XiriGoEcommerce

// MARK: - XGElevationTests

@Suite("XGElevation Tests")
struct XGElevationTests {
    // MARK: - Level0 (No Elevation)

    @Test("Level0 has zero radius and zero opacity")
    func test_level0_hasNoShadow() {
        #expect(XGElevation.level0.radius == 0)
        #expect(XGElevation.level0.y == 0)
        #expect(XGElevation.level0.opacity == 0)
    }

    // MARK: - Level1 (Lowest Elevation)

    @Test("Level1 has low radius and low opacity")
    func test_level1_hasLowShadow() {
        #expect(XGElevation.level1.radius == 1)
        #expect(XGElevation.level1.y == 1)
        #expect(XGElevation.level1.opacity == 0.15)
    }

    // MARK: - Level2

    @Test("Level2 has medium-low radius")
    func test_level2_hasMediumLowShadow() {
        #expect(XGElevation.level2.radius == 3)
        #expect(XGElevation.level2.y == 2)
        #expect(XGElevation.level2.opacity == 0.20)
    }

    // MARK: - Level3

    @Test("Level3 has medium radius")
    func test_level3_hasMediumShadow() {
        #expect(XGElevation.level3.radius == 6)
        #expect(XGElevation.level3.y == 4)
        #expect(XGElevation.level3.opacity == 0.25)
    }

    // MARK: - Level4

    @Test("Level4 has high radius")
    func test_level4_hasHighShadow() {
        #expect(XGElevation.level4.radius == 8)
        #expect(XGElevation.level4.y == 6)
        #expect(XGElevation.level4.opacity == 0.25)
    }

    // MARK: - Level5 (Highest Elevation)

    @Test("Level5 has highest radius and opacity")
    func test_level5_hasHighestShadow() {
        #expect(XGElevation.level5.radius == 12)
        #expect(XGElevation.level5.y == 8)
        #expect(XGElevation.level5.opacity == 0.30)
    }

    // MARK: - Ascending Order

    @Test("Shadow radius increases with elevation level")
    func test_levels_radiusIsAscending() {
        #expect(XGElevation.level0.radius < XGElevation.level1.radius)
        #expect(XGElevation.level1.radius < XGElevation.level2.radius)
        #expect(XGElevation.level2.radius < XGElevation.level3.radius)
        #expect(XGElevation.level3.radius < XGElevation.level4.radius)
        #expect(XGElevation.level4.radius < XGElevation.level5.radius)
    }

    @Test("Shadow y-offset increases with elevation level")
    func test_levels_yOffsetIsAscending() {
        #expect(XGElevation.level0.y < XGElevation.level1.y)
        #expect(XGElevation.level1.y < XGElevation.level2.y)
        #expect(XGElevation.level2.y < XGElevation.level3.y)
        #expect(XGElevation.level3.y < XGElevation.level4.y)
        #expect(XGElevation.level4.y < XGElevation.level5.y)
    }

    // MARK: - ShadowStyle struct

    @Test("ShadowStyle stores radius correctly")
    func test_shadowStyle_storesRadius() {
        let style = ShadowStyle(radius: 5, y: 3, opacity: 0.2)
        #expect(style.radius == 5)
    }

    @Test("ShadowStyle stores y-offset correctly")
    func test_shadowStyle_storesYOffset() {
        let style = ShadowStyle(radius: 5, y: 3, opacity: 0.2)
        #expect(style.y == 3)
    }

    @Test("ShadowStyle stores opacity correctly")
    func test_shadowStyle_storesOpacity() {
        let style = ShadowStyle(radius: 5, y: 3, opacity: 0.2)
        #expect(style.opacity == 0.2)
    }
}
