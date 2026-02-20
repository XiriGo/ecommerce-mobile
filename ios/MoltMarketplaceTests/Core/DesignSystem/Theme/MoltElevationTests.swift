import Testing
@testable import MoltMarketplace

// MARK: - MoltElevationTests

@Suite("MoltElevation Tests")
struct MoltElevationTests {
    // MARK: - Level0 (No Elevation)

    @Test("Level0 has zero radius and zero opacity")
    func test_level0_hasNoShadow() {
        #expect(MoltElevation.level0.radius == 0)
        #expect(MoltElevation.level0.y == 0)
        #expect(MoltElevation.level0.opacity == 0)
    }

    // MARK: - Level1 (Lowest Elevation)

    @Test("Level1 has low radius and low opacity")
    func test_level1_hasLowShadow() {
        #expect(MoltElevation.level1.radius == 1)
        #expect(MoltElevation.level1.y == 1)
        #expect(MoltElevation.level1.opacity == 0.15)
    }

    // MARK: - Level2

    @Test("Level2 has medium-low radius")
    func test_level2_hasMediumLowShadow() {
        #expect(MoltElevation.level2.radius == 3)
        #expect(MoltElevation.level2.y == 2)
        #expect(MoltElevation.level2.opacity == 0.20)
    }

    // MARK: - Level3

    @Test("Level3 has medium radius")
    func test_level3_hasMediumShadow() {
        #expect(MoltElevation.level3.radius == 6)
        #expect(MoltElevation.level3.y == 4)
        #expect(MoltElevation.level3.opacity == 0.25)
    }

    // MARK: - Level4

    @Test("Level4 has high radius")
    func test_level4_hasHighShadow() {
        #expect(MoltElevation.level4.radius == 8)
        #expect(MoltElevation.level4.y == 6)
        #expect(MoltElevation.level4.opacity == 0.25)
    }

    // MARK: - Level5 (Highest Elevation)

    @Test("Level5 has highest radius and opacity")
    func test_level5_hasHighestShadow() {
        #expect(MoltElevation.level5.radius == 12)
        #expect(MoltElevation.level5.y == 8)
        #expect(MoltElevation.level5.opacity == 0.30)
    }

    // MARK: - Ascending Order

    @Test("Shadow radius increases with elevation level")
    func test_levels_radiusIsAscending() {
        #expect(MoltElevation.level0.radius < MoltElevation.level1.radius)
        #expect(MoltElevation.level1.radius < MoltElevation.level2.radius)
        #expect(MoltElevation.level2.radius < MoltElevation.level3.radius)
        #expect(MoltElevation.level3.radius < MoltElevation.level4.radius)
        #expect(MoltElevation.level4.radius < MoltElevation.level5.radius)
    }

    @Test("Shadow y-offset increases with elevation level")
    func test_levels_yOffsetIsAscending() {
        #expect(MoltElevation.level0.y < MoltElevation.level1.y)
        #expect(MoltElevation.level1.y < MoltElevation.level2.y)
        #expect(MoltElevation.level2.y < MoltElevation.level3.y)
        #expect(MoltElevation.level3.y < MoltElevation.level4.y)
        #expect(MoltElevation.level4.y < MoltElevation.level5.y)
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
