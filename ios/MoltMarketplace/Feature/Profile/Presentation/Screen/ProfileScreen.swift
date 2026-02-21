import SwiftUI

// MARK: - ProfileScreen

/// User profile screen with guest state and menu items.
struct ProfileScreen: View {
    // MARK: - Properties

    @Environment(AppRouter.self) private var router

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: MoltSpacing.sectionSpacing) {
                guestHeader
                menuSection
            }
            .padding(.bottom, MoltSpacing.xl)
        }
        .background(MoltColors.background.ignoresSafeArea())
        .navigationTitle(String(localized: "nav_tab_profile"))
    }

    // MARK: - Guest Header

    private var guestHeader: some View {
        VStack(spacing: MoltSpacing.base) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: MoltSpacing.AvatarSize.extraLarge, height: MoltSpacing.AvatarSize.extraLarge)
                    .overlay(
                        Circle()
                            .stroke(MoltColors.outlineVariant, lineWidth: 1)
                    )

                Image(systemName: "person.fill")
                    .font(.system(size: MoltSpacing.IconSize.extraLarge))
                    .foregroundStyle(MoltColors.onSurfaceVariant)
            }

            Text(String(localized: "nav_profile_guest_title"))
                .font(MoltTypography.bodyLarge)
                .foregroundStyle(MoltColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            HStack(spacing: MoltSpacing.md) {
                MoltButton(
                    String(localized: "nav_profile_guest_login_button"),
                    variant: .primary,
                    fullWidth: false
                ) {
                    router.presentLogin()
                }

                MoltButton(
                    String(localized: "nav_profile_guest_register_button"),
                    variant: .outlined,
                    fullWidth: false
                ) {
                    router.navigate(to: .register)
                }
            }
        }
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
        .padding(.top, MoltSpacing.lg)
    }

    // MARK: - Menu Section

    private var menuSection: some View {
        VStack(spacing: MoltSpacing.xs) {
            ForEach(ProfileMenuItem.items, id: \.id) { item in
                menuRow(item)
            }
        }
        .padding(.horizontal, MoltSpacing.screenPaddingHorizontal)
    }

    private func menuRow(_ item: ProfileMenuItem) -> some View {
        Button {
            router.navigate(to: item.route)
        } label: {
            HStack(spacing: MoltSpacing.md) {
                Image(systemName: item.icon)
                    .foregroundStyle(MoltColors.primary)
                    .font(.system(size: MoltSpacing.IconSize.medium))
                    .frame(width: MoltSpacing.IconSize.large)
                    .accessibilityHidden(true)

                Text(item.title)
                    .font(MoltTypography.bodyLarge)
                    .foregroundStyle(MoltColors.onSurface)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(MoltColors.onSurfaceVariant)
                    .font(.system(size: MoltSpacing.IconSize.small))
                    .accessibilityHidden(true)
            }
            .padding(MoltSpacing.cardPadding)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: MoltCornerRadius.medium))
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
