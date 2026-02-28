import SwiftUI

// MARK: - ProfileScreen

/// User profile screen with guest state and menu items.
struct ProfileScreen: View {
    // MARK: - Properties

    @Environment(AppRouter.self) private var router

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: XGSpacing.sectionSpacing) {
                guestHeader
                menuSection
            }
            .padding(.bottom, XGSpacing.xl)
        }
        .background(XGColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_profile"))
    }

    // MARK: - Guest Header

    private var guestHeader: some View {
        VStack(spacing: XGSpacing.base) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: XGSpacing.AvatarSize.extraLarge, height: XGSpacing.AvatarSize.extraLarge)
                    .overlay(
                        Circle()
                            .stroke(XGColors.outlineVariant, lineWidth: 1)
                    )

                Image(systemName: "person.fill")
                    .font(.system(size: XGSpacing.IconSize.extraLarge))
                    .foregroundStyle(XGColors.onSurfaceVariant)
            }

            Text(String(localized: "nav_profile_guest_title"))
                .font(XGTypography.bodyLarge)
                .foregroundStyle(XGColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            HStack(spacing: XGSpacing.md) {
                XGButton(
                    String(localized: "nav_profile_guest_login_button"),
                    variant: .primary,
                    fullWidth: false
                ) {
                    router.presentLogin()
                }

                XGButton(
                    String(localized: "nav_profile_guest_register_button"),
                    variant: .outlined,
                    fullWidth: false
                ) {
                    router.navigate(to: .register)
                }
            }
        }
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
        .padding(.top, XGSpacing.lg)
    }

    // MARK: - Menu Section

    private var menuSection: some View {
        VStack(spacing: XGSpacing.xs) {
            ForEach(ProfileMenuItem.items, id: \.id) { item in
                menuRow(item)
            }
        }
        .padding(.horizontal, XGSpacing.screenPaddingHorizontal)
    }

    private func menuRow(_ item: ProfileMenuItem) -> some View {
        Button {
            router.navigate(to: item.route)
        } label: {
            HStack(spacing: XGSpacing.md) {
                Image(systemName: item.icon)
                    .foregroundStyle(XGColors.primary)
                    .font(.system(size: XGSpacing.IconSize.medium))
                    .frame(width: XGSpacing.IconSize.large)
                    .accessibilityHidden(true)

                Text(item.title)
                    .font(XGTypography.bodyLarge)
                    .foregroundStyle(XGColors.onSurface)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(XGColors.onSurfaceVariant)
                    .font(.system(size: XGSpacing.IconSize.small))
                    .accessibilityHidden(true)
            }
            .padding(XGSpacing.cardPadding)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: XGCornerRadius.medium))
        }
        .accessibilityLabel(item.title)
    }
}

// MARK: - Profile Menu Item

private struct ProfileMenuItem: Identifiable {
    let id: String
    let title: String
    let icon: String
    let route: Route

    static let items: [ProfileMenuItem] = [
        ProfileMenuItem(
            id: "orders",
            title: String(localized: "profile_menu_orders"),
            icon: "list.clipboard",
            route: .orderList
        ),
        ProfileMenuItem(
            id: "wishlist",
            title: String(localized: "profile_menu_wishlist"),
            icon: "heart",
            route: .wishlist
        ),
        ProfileMenuItem(
            id: "addresses",
            title: String(localized: "profile_menu_addresses"),
            icon: "mappin.and.ellipse",
            route: .addressManagement
        ),
        ProfileMenuItem(
            id: "payment",
            title: String(localized: "profile_menu_payment"),
            icon: "creditcard",
            route: .paymentMethods
        ),
        ProfileMenuItem(
            id: "notifications",
            title: String(localized: "profile_menu_notifications"),
            icon: "bell",
            route: .notifications
        ),
        ProfileMenuItem(
            id: "settings",
            title: String(localized: "profile_menu_settings"),
            icon: "gearshape",
            route: .settings
        ),
    ]
}

// MARK: - Previews

#Preview("ProfileScreen") {
    NavigationStack {
        ProfileScreen()
    }
    .environment(AppRouter())
}
